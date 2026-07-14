import 'exceptions.dart';
import 'http.dart';
import 'models/config.dart';
import 'models/create_order.dart';
import 'models/query_order.dart';
import 'models/refund.dart';
import 'receive_code.dart';
import 'signing.dart';
import 'token_cache.dart';

/// The main entry point for the Telebirr SDK.
///
/// Validates the environment configuration on construction and exposes
/// a [payments] accessor for all payment operations.
///
/// Example:
/// ```dart
/// final sdk = Telebirr(TelebirrConfig(
///   environment: Environment.sandbox,
///   fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
///   merchantAppId: '12345',
///   merchantCode: 'TEST_MERCHANT',
///   appSecret: 'sk_test_xxx',
///   privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...',
///   shortCode: '220311',
///   timeout: '120m',
///   notifyUrl: 'https://example.com/webhook',
/// ));
///
/// final response = await sdk.payments.charge(CreateOrderParams(
///   amount: '100',
///   title: 'Test Order',
/// ));
/// ```
class Telebirr {
  /// The SDK configuration containing credentials and environment settings.
  late final TelebirrConfig _config;

  /// Creates a [Telebirr] SDK instance with the given [config].
  ///
  /// Validates that the API key prefix matches the target environment:
  /// - `sk_test_*` keys must use [Environment.sandbox].
  /// - `sk_live_*` keys must use [Environment.production].
  ///
  /// Throws [EnvironmentException] if the key and environment mismatch.
  Telebirr(TelebirrConfig config) {
    _validateEnvironment(config);
    _config = config;
  }

  /// Provides access to payment operations (charge, query, refund).
  Payments get payments => Payments(_config);

  /// Validates that the API key prefix is appropriate for the target environment.
  ///
  /// Throws [EnvironmentException] if a test key is used in production
  /// or a live key is used in sandbox.
  static void _validateEnvironment(TelebirrConfig config) {
    final secret = config.appSecret;
    if (secret.startsWith('sk_test_') &&
        config.environment == Environment.production) {
      throw EnvironmentException(
        'Test key sk_test_ cannot be used in production environment',
      );
    }
    if (secret.startsWith('sk_live_') &&
        config.environment == Environment.sandbox) {
      throw EnvironmentException(
        'Live key sk_live_ cannot be used in sandbox environment',
      );
    }
  }
}

/// Handles all payment operations: creating orders, querying status, and refunds.
///
/// Maintains an internal [TokenCache] to avoid redundant token requests.
/// Obtain an instance via [Telebirr.payments].
///
/// Example:
/// ```dart
/// final payments = sdk.payments;
/// final order = await payments.charge(CreateOrderParams(
///   amount: '100',
///   title: 'Subscription',
/// ));
/// ```
class Payments {
  /// The SDK configuration used for API requests.
  final TelebirrConfig _config;

  /// Cache for the fabric token to avoid repeated token requests.
  final TokenCache _tokenCache = TokenCache();

  /// Creates a [Payments] instance with the given [config].
  Payments(this._config);

  /// Creates a new payment order and returns a [CreateOrderResponse].
  ///
  /// This method:
  /// 1. Obtains a fabric token (from cache or via token endpoint).
  /// 2. Generates a unique order ID if [CreateOrderParams.orderId] is not provided.
  /// 3. Builds and signs the request body.
  /// 4. POSTs to the create-order endpoint.
  /// 5. Constructs a receive code from the response's `prepay_id`.
  ///
  /// [params] contains the payment amount, title, and optional fields.
  /// [tradeType] specifies the payment flow. Defaults to [TradeType.inApp].
  ///
  /// Returns a [CreateOrderResponse] containing the `prepay_id` and
  /// `receiveCode` needed to initiate the payment on the client.
  ///
  /// Throws [TelebirrException] if the API returns a non-zero code.
  /// Throws [NetworkException] if the HTTP request fails.
  ///
  /// Example:
  /// ```dart
  /// final response = await payments.charge(
  ///   CreateOrderParams(amount: '500', title: 'Premium Plan'),
  ///   tradeType: TradeType.inApp,
  /// );
  /// print('Prepay ID: ${response.prepayId}');
  /// ```
  Future<CreateOrderResponse> charge(
    CreateOrderParams params, {
    TradeType tradeType = TradeType.inApp,
  }) async {
    // 1. Get token
    final token = await _getToken();

    // 2. Generate unique order ID if not provided
    final orderId = params.orderId ?? _generateOrderId();

    // 3. Build request body
    final bizContent = <String, dynamic>{
      'notify_url': _config.notifyUrl,
      'business_type': 'BuyGoods',
      'trade_type': tradeType.value,
      'appid': _config.merchantAppId,
      'merch_code': _config.merchantCode,
      'merch_order_id': orderId,
      'title': params.title,
      'total_amount': params.amount,
      'trans_currency': 'ETB',
      'timeout_express': _config.timeout,
      'payee_identifier': _config.shortCode,
      'payee_identifier_type': '04',
      'payee_type': '5000',
    };

    if (params.redirectUrl != null) {
      bizContent['redirect_url'] = params.redirectUrl;
    }
    if (params.callbackInfo != null) {
      bizContent['callback_info'] = params.callbackInfo;
    }

    final body = <String, dynamic>{
      'nonce_str': _generateNonceStr(),
      'method': 'payment.preorder',
      'timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'version': '1.0',
      'sign_type': 'SHA256WithRSA',
      'biz_content': bizContent,
    };

    // 4. Sign
    final sign = await signRequest(body, _config.privateKeyPem);
    body['sign'] = sign;

    // 5. POST
    final url =
        '${_config.effectiveBaseUrl}/payment/v1/merchant/inapp/createOrder';
    final response = await postJson(
      url,
      body,
      headers: {
        'X-APP-Key': _config.fabricAppId,
        'Authorization': token,
      },
    );

    final code = response['code']?.toString() ?? '';
    if (code != '0') {
      final message = response['message']?.toString() ??
          response['biz_content']?['message']?.toString();
      throw TelebirrException(
        message ?? 'CreateOrder failed',
        code: code,
      );
    }

    final bizResp =
        response['biz_content'] as Map<String, dynamic>? ?? {};
    final prepayId = bizResp['prepay_id']?.toString() ?? '';
    if (prepayId.isEmpty) {
      throw TelebirrException('No prepay_id in response', code: code);
    }

    final receiveCode = buildReceiveCode(
      _config.shortCode,
      params.amount,
      prepayId,
      _config.timeout,
    );

    return CreateOrderResponse(
      code: code,
      message: response['message']?.toString(),
      prepayId: prepayId,
      receiveCode: receiveCode,
      rawResponse: response,
    );
  }

  /// Queries the status of an existing order.
  ///
  /// [params] contains the merchant order ID to look up.
  ///
  /// Returns a [QueryOrderResponse] with the mapped [PaymentStatus].
  ///
  /// Throws [NetworkException] if the HTTP request fails.
  ///
  /// Example:
  /// ```dart
  /// final response = await payments.query(
  ///   QueryOrderParams(merchOrderId: 'ORDER_12345'),
  /// );
  /// if (response.status == PaymentStatus.success) {
  ///   print('Paid!');
  /// }
  /// ```
  Future<QueryOrderResponse> query(QueryOrderParams params) async {
    final token = await _getToken();

    final body = <String, dynamic>{
      'nonce_str': _generateNonceStr(),
      'method': 'payment.queryorder',
      'timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'version': '1.0',
      'sign_type': 'SHA256WithRSA',
      'biz_content': {
        'appid': _config.merchantAppId,
        'merch_code': _config.merchantCode,
        'merch_order_id': params.merchOrderId,
      },
    };

    final sign = await signRequest(body, _config.privateKeyPem);
    body['sign'] = sign;

    final url =
        '${_config.effectiveBaseUrl}/payment/v1/merchant/queryOrder';
    final response = await postJson(
      url,
      body,
      headers: {
        'X-APP-Key': _config.fabricAppId,
        'Authorization': token,
      },
    );

    final code = response['code']?.toString() ?? '';
    final bizResp =
        response['biz_content'] as Map<String, dynamic>? ?? {};
    final tradeStatus = bizResp['trade_status']?.toString() ?? '';

    return QueryOrderResponse(
      code: code,
      status: mapTelebirrStatus(tradeStatus),
      rawResponse: response,
    );
  }

  /// Requests a refund for a previously paid order.
  ///
  /// [params] contains the original order ID, refund request number,
  /// refund amount, and optional reason.
  ///
  /// Returns a [RefundResponse] with the refund status and order ID.
  ///
  /// Throws [ValidationException] if required fields are missing or invalid:
  /// - [RefundParams.merchOrderId] must not be empty.
  /// - [RefundParams.refundRequestNo] must not be empty.
  /// - [RefundParams.refundAmount] must be a positive number.
  ///
  /// Throws [TelebirrException] if the API returns a non-zero code.
  /// Throws [NetworkException] if the HTTP request fails.
  ///
  /// Example:
  /// ```dart
  /// final response = await payments.refund(RefundParams(
  ///   merchOrderId: 'ORDER_12345',
  ///   refundRequestNo: 'REFUND_001',
  ///   refundAmount: '100',
  ///   refundReason: 'Customer request',
  /// ));
  /// ```
  Future<RefundResponse> refund(RefundParams params) async {
    if (params.merchOrderId.isEmpty) {
      throw ValidationException('merchOrderId is required');
    }
    if (params.refundRequestNo.isEmpty) {
      throw ValidationException('refundRequestNo is required');
    }
    if (params.refundAmount.isEmpty ||
        double.tryParse(params.refundAmount) == null ||
        double.parse(params.refundAmount) <= 0) {
      throw ValidationException('refundAmount must be a positive number');
    }

    final token = await _getToken();

    final body = <String, dynamic>{
      'nonce_str': _generateNonceStr(),
      'method': 'payment.refund',
      'timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'version': '1.0',
      'sign_type': 'SHA256WithRSA',
      'biz_content': {
        'appid': _config.merchantAppId,
        'merch_code': _config.merchantCode,
        'merch_order_id': params.merchOrderId,
        'refund_request_no': params.refundRequestNo,
        'refund_amount': params.refundAmount,
        if (params.refundReason != null) 'refund_reason': params.refundReason,
      },
    };

    final sign = await signRequest(body, _config.privateKeyPem);
    body['sign'] = sign;

    final url = '${_config.effectiveBaseUrl}/payment/v1/merchant/refund';
    final response = await postJson(
      url,
      body,
      headers: {
        'X-APP-Key': _config.fabricAppId,
        'Authorization': token,
      },
    );

    final code = response['code']?.toString() ?? '';
    if (code != '0') {
      final message = response['message']?.toString() ??
          response['biz_content']?['message']?.toString();
      throw TelebirrException(
        message ?? 'Refund failed',
        code: code,
      );
    }

    final bizResp =
        response['biz_content'] as Map<String, dynamic>? ?? {};

    return RefundResponse(
      code: code,
      message: response['message']?.toString(),
      refundOrderId: bizResp['refund_order_id']?.toString(),
      refundStatus: bizResp['refund_status']?.toString(),
      rawResponse: response,
    );
  }

  /// Builds a receive code for a known [prepayId].
  ///
  /// This is a convenience method for constructing a receive code when
  /// you already have the `prepay_id` (e.g., from a previous order
  /// creation response) but need to rebuild the code.
  ///
  /// Uses `'0'` as the amount and the configured [TelebirrConfig.shortCode]
  /// and [TelebirrConfig.timeout].
  ///
  /// [prepayId] is the prepay ID from a previous create-order response.
  ///
  /// Returns the formatted receive code string.
  String buildReceiveCodeForPrepayId(String prepayId) {
    return buildReceiveCode(
      _config.shortCode,
      '0',
      prepayId,
      _config.timeout,
    );
  }

  /// Obtains a fabric token, using the cache when available.
  ///
  /// Returns the cached token if it exists and has not expired.
  /// Otherwise, requests a new token from the `/payment/v1/token` endpoint
  /// and caches it.
  ///
  /// Throws [NetworkException] if the token request fails.
  Future<String> _getToken() async {
    final cached = _tokenCache.get();
    if (cached != null) return cached;

    final url = '${_config.effectiveBaseUrl}/payment/v1/token';
    final response = await postJson(
      url,
      {'appSecret': _config.appSecret},
      headers: {'X-APP-Key': _config.fabricAppId},
    );

    final code = response['code']?.toString() ?? '';
    if (code != '0') {
      throw NetworkException(
        'Token request failed: ${response['message'] ?? response}',
        code: 'TOKEN_FAILED',
      );
    }

    final token = response['token']?.toString() ?? '';
    _tokenCache.set(token);
    return token;
  }

  /// Generates a unique order ID based on the current timestamp.
  ///
  /// Format: `{millisecondsSinceEpoch}{5-digit-random-suffix}`.
  ///
  /// Returns a numeric string suitable for use as `merch_order_id`.
  static String _generateOrderId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now % 100000).toString().padLeft(5, '0');
    return '$now$random';
  }

  /// Generates a 32-character uppercase alphanumeric nonce string.
  ///
  /// Used as the `nonce_str` field in API requests. The generation is
  /// deterministic based on the current microsecond timestamp, though
  /// not cryptographically random.
  static String _generateNonceStr() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < 32; i++) {
      buffer.write(chars[(now + i * 7) % chars.length]);
    }
    return buffer.toString();
  }
}

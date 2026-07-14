/// The type of trade/payment flow to initiate.
///
/// Each value corresponds to a Telebirr `trade_type` string and determines
/// how the payment is presented to the end user.
enum TradeType {
  /// In-app payment via the mobile SDK.
  inApp('InApp'),

  /// Cross-app payment flow.
  crossApp('Cross-App'),

  /// Web checkout payment flow.
  webCheckout('WebCheckout'),

  /// Progressive Web App payment flow.
  pwa('PWA'),

  /// QR code scan payment flow.
  qrCode('QrCode'),

  /// Quick pay flow.
  quickPay('QuickPay'),

  /// Bank trade payment flow.
  bankTrade('BankTrade');

  /// The Telebirr API string value for this trade type.
  final String value;

  /// Creates a [TradeType] with the given API [value].
  const TradeType(this.value);
}

/// Parameters for creating a new payment order.
///
/// Only [amount] and [title] are required. All other fields are optional
/// and will use sensible defaults when not provided.
///
/// Example:
/// ```dart
/// final params = CreateOrderParams(
///   amount: '100',
///   title: 'Premium Subscription',
///   orderId: 'ORDER_12345',
/// );
/// ```
class CreateOrderParams {
  /// The payment amount in ETB (Ethiopian Birr).
  ///
  /// Must be a positive numeric string, e.g., `'100'` or `'99.50'`.
  final String amount;

  /// A short description or title for the order.
  ///
  /// Displayed to the user during the payment flow.
  final String title;

  /// An optional unique order identifier.
  ///
  /// If not provided, one is auto-generated using a timestamp-based scheme.
  /// Use this for idempotency or to track orders in your own system.
  final String? orderId;

  /// An optional URL to redirect the user to after payment completes.
  ///
  /// Only applicable for web-based trade types (e.g., [TradeType.webCheckout]).
  final String? redirectUrl;

  /// Optional callback information passed through to the webhook notification.
  ///
  /// This value is echoed back in the [NotificationPayload.callbackInfo] field
  /// of the webhook notification, allowing you to correlate the notification
  /// with your internal order.
  final String? callbackInfo;

  /// Creates a [CreateOrderParams] with the given payment details.
  const CreateOrderParams({
    required this.amount,
    required this.title,
    this.orderId,
    this.redirectUrl,
    this.callbackInfo,
  });
}

/// The response from a successful create-order API call.
///
/// Contains the [prepayId] needed to initiate the actual payment flow,
/// and a [receiveCode] for QR-code-based payment.
///
/// Example:
/// ```dart
/// final response = await payments.charge(params);
/// print('Prepay ID: ${response.prepayId}');
/// print('Receive code: ${response.receiveCode}');
/// ```
class CreateOrderResponse {
  /// The Telebirr API response code.
  ///
  /// `'0'` indicates success; any other value indicates an error.
  final String code;

  /// An optional human-readable message from the API.
  ///
  /// May contain error details when [code] is not `'0'`.
  final String? message;

  /// The prepay ID returned by Telebirr.
  ///
  /// This unique identifier is used to start the actual payment flow
  /// on the client side (e.g., passing it to the Telebirr mobile SDK).
  final String prepayId;

  /// A receive code formatted as `TELEBIRR$BUYGOODS{shortCode}{amount}{prepayId}%{timeout}`.
  ///
  /// Used for QR-code-based payment flows where the user scans a code
  /// to initiate payment.
  final String receiveCode;

  /// The full raw response map from the Telebirr API.
  ///
  /// Useful for accessing any fields not explicitly modeled in this class.
  final Map<String, dynamic> rawResponse;

  /// Creates a [CreateOrderResponse] with the order creation result.
  const CreateOrderResponse({
    required this.code,
    this.message,
    required this.prepayId,
    required this.receiveCode,
    required this.rawResponse,
  });
}

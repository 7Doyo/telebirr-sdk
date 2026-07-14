/// Represents the Telebirr API environment.
///
/// Each environment maps to a different base URL and is validated against
/// the API key prefix to prevent accidental misuse.
enum Environment {
  /// The sandbox/test environment for development and testing.
  ///
  /// Base URL: `https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway`
  sandbox,

  /// The live production environment for real transactions.
  ///
  /// Base URL: `https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway`
  production,
}

/// Configuration for the Telebirr SDK.
///
/// Contains all credentials and settings needed to interact with the
/// Telebirr payment gateway API.
///
/// Example:
/// ```dart
/// final config = TelebirrConfig(
///   environment: Environment.sandbox,
///   fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
///   merchantAppId: '12345',
///   merchantCode: 'TEST_MERCHANT',
///   appSecret: 'sk_test_xxx',
///   privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...',
///   shortCode: '220311',
///   timeout: '120m',
///   notifyUrl: 'https://example.com/webhook',
/// );
/// ```
class TelebirrConfig {
  /// The target environment (sandbox or production).
  final Environment environment;

  /// The fabric application ID (UUID format) from the Telebirr developer portal.
  ///
  /// Used in the `X-APP-Key` header for all API requests.
  final String fabricAppId;

  /// The numeric merchant application ID.
  ///
  /// Included in the `biz_content.appid` field of order requests.
  final String merchantAppId;

  /// The merchant code assigned by Ethio Telecom.
  ///
  /// Included in the `biz_content.merch_code` field of order requests.
  final String merchantCode;

  /// The application secret used to obtain fabric tokens.
  ///
  /// Expected to start with `sk_test_` for sandbox or `sk_live_` for production.
  /// Sent in the token request body as `appSecret`.
  final String appSecret;

  /// The PKCS#8 PEM-encoded RSA private key used for request signing.
  ///
  /// Must be a valid PEM string starting with `-----BEGIN PRIVATE KEY-----`.
  /// Requests are signed using SHA256withRSA-PSS with a 32-byte salt.
  final String privateKeyPem;

  /// The merchant short code (e.g., `'220311'`).
  ///
  /// Used as the `payee_identifier` in order requests and as part of
  /// the receive code.
  final String shortCode;

  /// The payment timeout express value (e.g., `'120m'`).
  ///
  /// Specifies how long the order remains payable before expiring.
  final String timeout;

  /// The webhook URL that receives payment notification callbacks.
  ///
  /// Must be a publicly accessible HTTPS URL.
  final String notifyUrl;

  /// An optional override for the API base URL.
  ///
  /// When `null`, the base URL is automatically determined from [environment].
  /// Provide this to use a custom or proxied endpoint.
  final String? baseUrl;

  /// Creates a [TelebirrConfig] with the required credentials and settings.
  ///
  /// All parameters except [baseUrl] are required.
  const TelebirrConfig({
    required this.environment,
    required this.fabricAppId,
    required this.merchantAppId,
    required this.merchantCode,
    required this.appSecret,
    required this.privateKeyPem,
    required this.shortCode,
    required this.timeout,
    required this.notifyUrl,
    this.baseUrl,
  });

  /// Returns the effective base URL for API requests.
  ///
  /// If [baseUrl] is provided, it is returned directly. Otherwise, the
  /// default URL for the current [environment] is used:
  /// - Sandbox: `https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway`
  /// - Production: `https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway`
  String get effectiveBaseUrl {
    if (baseUrl != null) return baseUrl!;
    return environment == Environment.sandbox
        ? 'https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway'
        : 'https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway';
  }
}

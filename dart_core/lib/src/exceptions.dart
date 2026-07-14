/// Base exception class for all Telebirr SDK errors.
///
/// All SDK-specific exceptions extend this class, allowing callers to
/// catch any SDK error with a single `catch` clause on [TelebirrException].
///
/// Example:
/// ```dart
/// try {
///   await payments.charge(params);
/// } on TelebirrException catch (e) {
///   print('Error ${e.code}: ${e.message}');
/// }
/// ```
class TelebirrException implements Exception {
  /// A human-readable error message describing what went wrong.
  final String message;

  /// A machine-readable error code identifying the error category.
  ///
  /// Defaults to `'UNKNOWN'` when no specific code is provided.
  final String code;

  /// Creates a [TelebirrException] with the given [message] and optional [code].
  TelebirrException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => 'TelebirrException($code): $message';
}

/// Exception thrown when input validation fails.
///
/// This occurs when required parameters are missing, have invalid formats,
/// or violate business rules (e.g., a non-positive refund amount).
///
/// Example:
/// ```dart
/// try {
///   await payments.refund(params);
/// } on ValidationException catch (e) {
///   print('Validation error: ${e.message}');
/// }
/// ```
class ValidationException extends TelebirrException {
  /// Creates a [ValidationException] with the given [message] and optional [code].
  ValidationException(super.message, {super.code = 'VALIDATION'});
}

/// Exception thrown when request signing or signature verification fails.
///
/// This can happen due to an invalid private key, malformed PEM, or
/// errors during the RSA-PSS signing process.
///
/// Example:
/// ```dart
/// try {
///   await payments.charge(params);
/// } on SigningException catch (e) {
///   print('Signing error: ${e.message}');
/// }
/// ```
class SigningException extends TelebirrException {
  /// Creates a [SigningException] with the given [message] and optional [code].
  SigningException(super.message, {super.code = 'SIGNING'});
}

/// Exception thrown when an HTTP request to the Telebirr API fails.
///
/// This covers connection errors, non-2xx HTTP status codes, and
/// malformed response bodies.
///
/// Example:
/// ```dart
/// try {
///   await payments.charge(params);
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
/// }
/// ```
class NetworkException extends TelebirrException {
  /// Creates a [NetworkException] with the given [message] and optional [code].
  NetworkException(super.message, {super.code = 'NETWORK'});
}

/// Exception thrown when the SDK is configured with mismatched environment keys.
///
/// For example, using a test key (`sk_test_*`) with the production environment
/// or a live key (`sk_live_*`) with the sandbox environment.
///
/// Example:
/// ```dart
/// try {
///   final sdk = Telebirr(config);
/// } on EnvironmentException catch (e) {
///   print('Config error: ${e.message}');
/// }
/// ```
class EnvironmentException extends TelebirrException {
  /// Creates an [EnvironmentException] with the given [message] and optional [code].
  EnvironmentException(super.message, {super.code = 'ENVIRONMENT'});
}

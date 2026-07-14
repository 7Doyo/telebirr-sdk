/// Trade status values for webhook notification payloads.
///
/// These use **camelCase** strings (e.g., `'Completed'`, `'Failure'`),
/// which differ from the UPPER_CASE strings returned by the query-order API.
///
/// See also [parseNotificationTradeStatus] for converting raw strings.
enum NotificationTradeStatus {
  /// Payment is in progress.
  paying('Paying'),

  /// Payment expired before completion.
  expired('Expired'),

  /// Awaiting payment from the user.
  pending('Pending'),

  /// Payment completed successfully.
  completed('Completed'),

  /// Payment failed.
  failure('Failure');

  /// The Telebirr API string value for this status.
  final String value;

  /// Creates a [NotificationTradeStatus] with the given API [value].
  const NotificationTradeStatus(this.value);
}

/// Parses a raw [value] string into a [NotificationTradeStatus] enum.
///
/// Returns `null` if the [value] does not match any known status.
///
/// Example:
/// ```dart
/// final status = parseNotificationTradeStatus('Completed');
/// assert(status == NotificationTradeStatus.completed);
/// ```
NotificationTradeStatus? parseNotificationTradeStatus(String value) {
  return NotificationTradeStatus.values.cast<NotificationTradeStatus?>().firstWhere(
        (s) => s!.value == value,
        orElse: () => null,
      );
}

/// A parsed Telebirr webhook notification payload.
///
/// Wraps the raw JSON map and provides typed accessors for each known field.
/// Fields that are absent or `null` in the payload return `null`.
///
/// Example:
/// ```dart
/// final payload = NotificationPayload(jsonMap);
/// print('Order: ${payload.merchOrderId}');
/// print('Status: ${payload.tradeStatus}');
/// ```
class NotificationPayload {
  /// The raw JSON map from the webhook request body.
  final Map<String, dynamic> raw;

  /// Creates a [NotificationPayload] wrapping the given [raw] map.
  const NotificationPayload(this.raw);

  /// The webhook notification URL.
  String? get notifyUrl => raw['notify_url']?.toString();

  /// The application ID that initiated the order.
  String? get appId => raw['appid']?.toString();

  /// The timestamp when the notification was sent (ISO 8601 format).
  String? get notifyTime => raw['notify_time']?.toString();

  /// The merchant code.
  String? get merchCode => raw['merch_code']?.toString();

  /// The merchant order ID from the original create-order request.
  String? get merchOrderId => raw['merch_order_id']?.toString();

  /// The Telebirr payment order ID.
  String? get paymentOrderId => raw['payment_order_id']?.toString();

  /// The total payment amount in ETB.
  String? get totalAmount => raw['total_amount']?.toString();

  /// The transaction currency (always `'ETB'`).
  String? get transCurrency => raw['trans_currency']?.toString();

  /// The trade status as a camelCase string (e.g., `'Completed'`).
  ///
  /// Use [parseNotificationTradeStatus] to convert this to a
  /// [NotificationTradeStatus] enum value.
  String? get tradeStatus => raw['trade_status']?.toString();

  /// The transaction end timestamp.
  String? get transEndTime => raw['trans_end_time']?.toString();

  /// The callback info echoed from the original create-order request.
  String? get callbackInfo => raw['callback_info']?.toString();

  /// The RSA-PSS signature for verifying the notification's authenticity.
  String? get sign => raw['sign']?.toString();

  /// The signature type used (e.g., `'SHA256WithRSA'`).
  String? get signType => raw['sign_type']?.toString();
}

/// Verifies the RSA-PSS signature of a webhook notification.
///
/// [payload] is the parsed notification payload.
/// [publicKeyPem] is the PEM-encoded RSA public key for verification.
///
/// Returns `true` if the signature is valid, `false` otherwise.
///
/// **Note:** This function is currently a placeholder that always returns
/// `false`. For production use, implement verification using the
/// `cryptography` package's [RsaPss] algorithm with SHA-256.
///
/// Example:
/// ```dart
/// if (verifyNotification(payload, publicKeyPem)) {
///   // Process the notification
/// }
/// ```
bool verifyNotification(
  NotificationPayload payload,
  String publicKeyPem,
) {
  final sign = payload.sign;
  if (sign == null || sign.isEmpty) return false;

  final signString = _buildNotificationSignString(payload.raw);
  // Verification requires the cryptography package
  // For now, we provide the sign string builder for external verification
  return _verifyPssSignature(signString, sign, publicKeyPem);
}

/// Builds the canonical signing string from a webhook notification payload.
///
/// This is the public wrapper around [_buildNotificationSignString] that
/// can be used for external signature verification.
///
/// [payload] is the raw notification JSON map.
///
/// Returns the canonical signing string with fields sorted alphabetically
/// and joined as `key=value` pairs with `&`.
///
/// Example:
/// ```dart
/// final signString = buildNotificationSignString(notificationMap);
/// // Use this with an external RSA verification library
/// ```
String buildNotificationSignString(Map<String, dynamic> payload) {
  return _buildNotificationSignString(payload);
}

/// Internal implementation that builds the signing string for notifications.
///
/// Excludes `sign` and `sort_type` fields, then sorts remaining keys
/// alphabetically and joins as `key=value` pairs.
String _buildNotificationSignString(Map<String, dynamic> payload) {
  const exclude = {'sign', 'sign_type'};
  final fields = <String>[];
  final fieldMap = <String, String>{};

  for (final key in payload.keys) {
    if (exclude.contains(key)) continue;
    final value = payload[key];
    if (value == null) continue;
    fields.add(key);
    fieldMap[key] = value.toString();
  }

  fields.sort();
  return fields.map((k) => '$k=${fieldMap[k]}').join('&');
}

/// Placeholder for RSA-PSS signature verification.
///
/// **Note:** This always returns `false`. In production, use the
/// `cryptography` package to verify the signature with the provided
/// [publicKeyPem].
bool _verifyPssSignature(String data, String signature, String publicKeyPem) {
  // Verification requires the cryptography package
  // This is a placeholder that always returns false
  // In production, use RsaPss from the cryptography package
  return false;
}

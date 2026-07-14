/// Builds the Telebirr receive code string from order components.
///
/// The receive code is formatted as:
/// `TELEBIRR$BUYGOODS{shortCode}{amount}{prepayId}%{timeout}`
///
/// This code is used in QR-code-based payment flows where the user scans
/// a code to initiate payment.
///
/// [shortCode] is the merchant short code (e.g., `'220311'`).
/// [amount] is the payment amount as a string (e.g., `'100'`).
/// [prepayId] is the prepay ID returned from the create-order API.
/// [timeout] is the payment timeout express value (e.g., `'120m'`).
///
/// Returns the formatted receive code string.
///
/// Example:
/// ```dart
/// final code = buildReceiveCode('220311', '100', 'PREPAY123', '120m');
/// // Returns 'TELEBIRR$BUYGOODS220311100PREPAY123%120m'
/// ```
String buildReceiveCode(
  String shortCode,
  String amount,
  String prepayId,
  String timeout,
) {
  return 'TELEBIRR\$BUYGOODS$shortCode$amount$prepayId%$timeout';
}

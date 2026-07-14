/// Formats a payment amount string with its currency code.
///
/// Returns a human-readable string like `"100 ETB"` by joining [amount]
/// and [currency] with a space.
///
/// ```dart
/// formatAmount('100');          // "100 ETB"
/// formatAmount('50', currency: 'USD'); // "50 USD"
/// ```
String formatAmount(String amount, {String currency = 'ETB'}) {
  return '$amount $currency';
}

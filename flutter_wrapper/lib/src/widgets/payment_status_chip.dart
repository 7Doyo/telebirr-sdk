import 'package:flutter/widgets.dart';
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

import '../l10n/telebirr_localizations.dart';

/// A small colored chip that displays a localized [PaymentStatus] label.
///
/// Each status maps to a distinct background and text color combination
/// (e.g. green for success, red for failure, yellow for pending).
/// The label text is resolved via [TelebirrLocalizations.statusLabel].
///
/// ```dart
/// PaymentStatusChip(status: PaymentStatus.success)
/// ```
class PaymentStatusChip extends StatelessWidget {
  /// The payment status to display.
  final PaymentStatus status;

  /// Creates a [PaymentStatusChip] for the given [status].
  const PaymentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (status) {
      PaymentStatus.success => (
          const Color(0xFFD4EDDA),
          const Color(0xFF155724),
        ),
      PaymentStatus.fail => (
          const Color(0xFFF8D7DA),
          const Color(0xFF721C24),
        ),
      PaymentStatus.timeout => (
          const Color(0xFFE2E3E5),
          const Color(0xFF383D41),
        ),
      PaymentStatus.pending => (
          const Color(0xFFFFF3CD),
          const Color(0xFF856404),
        ),
      PaymentStatus.accepted => (
          const Color(0xFFCCE5FF),
          const Color(0xFF004085),
        ),
      PaymentStatus.refunding => (
          const Color(0xFFD4EDDA),
          const Color(0xFF155724),
        ),
      PaymentStatus.refundSuccess => (
          const Color(0xFFD4EDDA),
          const Color(0xFF155724),
        ),
      PaymentStatus.refundFailed => (
          const Color(0xFFF8D7DA),
          const Color(0xFF721C24),
        ),
    };

    final l10n = TelebirrLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.statusLabel(status.name.toUpperCase()),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/telebirr_localizations.dart';

/// A styled error banner that displays an [errorMessage] with an optional dismiss button.
///
/// Returns a hidden widget (zero-size [SizedBox]) when [errorMessage] is `null`.
/// Otherwise renders a red-tinted container with an error icon, the message text,
/// and a close button if [onDismiss] is provided.
///
/// ```dart
/// ErrorDisplay(
///   errorMessage: 'Payment failed: insufficient funds',
///   onDismiss: () => setState(() => _error = null),
/// )
/// ```
class ErrorDisplay extends StatelessWidget {
  /// The error message to display, or `null` to hide the widget.
  final String? errorMessage;

  /// Optional callback invoked when the user taps the dismiss (close) button.
  /// If `null`, the dismiss button is not shown.
  final VoidCallback? onDismiss;

  /// Creates an [ErrorDisplay].
  ///
  /// Both [errorMessage] and [onDismiss] are optional.
  const ErrorDisplay({
    super.key,
    this.errorMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    final l10n = TelebirrLocalizations.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 4, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 16),
              color: const Color(0xFF991B1B),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: l10n.errorDismiss,
            ),
        ],
      ),
    );
  }
}

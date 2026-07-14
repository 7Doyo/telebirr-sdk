import 'package:flutter/material.dart';

import '../l10n/telebirr_localizations.dart';
import '../payment_notifier.dart';

/// An elevated button that triggers a payment and shows a loading indicator.
///
/// Listens to the provided [PaymentNotifier] to automatically disable itself
/// and show a spinner while a charge is in progress. When the notifier is idle,
/// pressing the button invokes [onPressed].
///
/// ```dart
/// PaymentButton(
///   notifier: paymentNotifier,
///   onPressed: () => paymentNotifier.charge(params),
/// )
/// ```
class PaymentButton extends StatelessWidget {
  /// The [PaymentNotifier] that drives the button's loading state.
  final PaymentNotifier notifier;

  /// Callback invoked when the button is pressed and [notifier] is not loading.
  final VoidCallback onPressed;

  /// Optional custom label text. Defaults to the localized "Pay Now" string.
  final String? label;

  /// Creates a [PaymentButton].
  ///
  /// The [notifier] determines when the button is disabled and shows a spinner.
  /// The [onPressed] callback is called on tap when the button is enabled.
  const PaymentButton({
    super.key,
    required this.notifier,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = TelebirrLocalizations.of(context);
    final displayLabel = label ?? l10n.payNow;

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return ElevatedButton(
          onPressed: notifier.isLoading ? null : onPressed,
          child: notifier.isLoading
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Text(displayLabel),
        );
      },
    );
  }
}

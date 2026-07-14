import 'package:flutter/material.dart';
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

import '../l10n/telebirr_localizations.dart';
import '../payment_notifier.dart';

/// A self-contained payment card that displays an order summary and a pay button.
///
/// Shows the [title], formatted [amount] with [currency], and manages the
/// payment lifecycle via [notifier]. Displays a loading spinner during the
/// charge, an error message on failure, and invokes [onSuccess] on completion.
///
/// ```dart
/// PaymentCardForm(
///   notifier: paymentNotifier,
///   title: 'Premium Subscription',
///   amount: '500',
///   currency: 'ETB',
///   onSuccess: () => Navigator.pop(context),
/// )
/// ```
class PaymentCardForm extends StatefulWidget {
  /// The [PaymentNotifier] that drives payment state and UI updates.
  final PaymentNotifier notifier;

  /// The order title displayed at the top of the card.
  final String title;

  /// The payment amount as a string (e.g. `'100'`).
  final String amount;

  /// The currency code displayed alongside [amount]. Defaults to `'ETB'`.
  final String currency;

  /// Called when the payment charge succeeds.
  final VoidCallback? onSuccess;

  /// Creates a [PaymentCardForm].
  ///
  /// The [notifier], [title], and [amount] are required.
  /// Defaults to Ethiopian Birr (`'ETB'`) if [currency] is not provided.
  const PaymentCardForm({
    super.key,
    required this.notifier,
    required this.title,
    required this.amount,
    this.currency = 'ETB',
    this.onSuccess,
  });

  @override
  State<PaymentCardForm> createState() => _PaymentCardFormState();
}

class _PaymentCardFormState extends State<PaymentCardForm> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (widget.notifier.state == PaymentState.success) {
      widget.onSuccess?.call();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _handlePay() {
    final params = CreateOrderParams(
      amount: widget.amount,
      title: widget.title,
    );
    widget.notifier.charge(params);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.amount} ${widget.currency}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (widget.notifier.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.notifier.errorMessage != null)
              Text(
                widget.notifier.errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else
              ElevatedButton(
                onPressed: _handlePay,
                child: Text(TelebirrLocalizations.of(context).payNow),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

import '../l10n/telebirr_localizations.dart';
import '../payment_notifier.dart';

/// A refund button that manages the full refund lifecycle: confirmation,
/// processing, success, and error states.
///
/// On first press, shows a confirmation dialog. On confirm, sends a refund
/// request using the provided [telebirr] instance. Displays a loading spinner
/// during processing, a green success banner on completion, or a red error
/// banner on failure.
///
/// ```dart
/// RefundButton(
///   telebirr: telebirr,
///   merchOrderId: 'order-123',
///   refundAmount: '100',
///   refundReason: 'Customer request',
///   onSuccess: () => refreshOrderList(),
///   onError: (e) => log(e),
/// )
/// ```
class RefundButton extends StatefulWidget {
  /// The [Telebirr] SDK instance used to execute the refund.
  final Telebirr telebirr;

  /// The merchant order ID of the order to refund.
  final String merchOrderId;

  /// The refund amount as a string (e.g. `'100'`).
  final String refundAmount;

  /// An optional reason describing why the refund is being issued.
  final String? refundReason;

  /// Called when the refund completes successfully.
  final VoidCallback? onSuccess;

  /// Called when the refund request fails.
  final VoidCallback? onError;

  /// Creates a [RefundButton].
  ///
  /// The [telebirr], [merchOrderId], and [refundAmount] are required.
  const RefundButton({
    super.key,
    required this.telebirr,
    required this.merchOrderId,
    required this.refundAmount,
    this.refundReason,
    this.onSuccess,
    this.onError,
  });

  @override
  State<RefundButton> createState() => _RefundButtonState();
}

class _RefundButtonState extends State<RefundButton> {
  late final RefundNotifier _notifier;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _notifier = RefundNotifier(widget.telebirr);
    _notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    _notifier.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (_notifier.state == RefundState.success) {
      setState(() => _showConfirm = false);
      widget.onSuccess?.call();
    }
    if (_notifier.state == RefundState.error) {
      widget.onError?.call();
    }
    if (mounted) setState(() {});
  }

  void _handleRefundPressed() {
    setState(() => _showConfirm = true);
  }

  void _handleConfirm() {
    final requestNo = 'RF${DateTime.now().millisecondsSinceEpoch}';
    _notifier.refund(
      RefundParams(
        merchOrderId: widget.merchOrderId,
        refundRequestNo: requestNo,
        refundAmount: widget.refundAmount,
        refundReason: widget.refundReason,
      ),
    );
  }

  void _handleCancel() {
    setState(() => _showConfirm = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = TelebirrLocalizations.of(context);

    if (_notifier.isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_notifier.state == RefundState.success) {
      return Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD4EDDA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF155724), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.refundSuccess,
                style: const TextStyle(color: Color(0xFF155724)),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifier.errorMessage != null) {
      return Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8D7DA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF721C24), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.refundFailed,
                style: const TextStyle(color: Color(0xFF721C24)),
              ),
            ),
          ],
        ),
      );
    }

    if (_showConfirm) {
      return Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.refundConfirm,
              style: const TextStyle(color: Color(0xFF856404)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _handleCancel,
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleConfirm,
                  child: Text(l10n.refund),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: _handleRefundPressed,
      child: Text(l10n.refund),
    );
  }
}

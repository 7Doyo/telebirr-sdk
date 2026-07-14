import 'package:flutter/material.dart';

import '../l10n/telebirr_localizations.dart';

/// An elevated button for retrying a failed operation.
///
/// When [loading] is `true`, the button is disabled and displays a circular
/// progress indicator. When `false`, pressing it invokes [onPressed].
///
/// ```dart
/// RetryButton(
///   loading: retryNotifier.isLoading,
///   onPressed: () => retryNotifier.chargeWithRetry(params),
/// )
/// ```
class RetryButton extends StatelessWidget {
  /// Callback invoked when the button is pressed and [loading] is `false`.
  final VoidCallback onPressed;

  /// Optional custom label text. Defaults to the localized "Retry" string.
  final String? label;

  /// Whether the button should show a loading spinner and be disabled.
  final bool loading;

  /// Creates a [RetryButton].
  ///
  /// The [onPressed] callback is required and fires on tap when [loading] is
  /// `false`. Defaults to `false` if [loading] is not provided.
  const RetryButton({
    super.key,
    required this.onPressed,
    this.label,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = TelebirrLocalizations.of(context);
    final displayLabel = label ?? l10n.retry;

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
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
  }
}

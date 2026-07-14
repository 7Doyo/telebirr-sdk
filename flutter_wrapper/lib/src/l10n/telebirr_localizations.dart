import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// The main localization class for the Telebirr Flutter SDK.
///
/// Provides access to all localized UI strings used by Telebirr widgets.
/// Supports custom string overrides via [customStrings] for complete control
/// over displayed text without modifying source translations.
///
/// ```dart
/// final l10n = TelebirrLocalizations.of(context);
/// Text(l10n.payNow);
/// ```
class TelebirrLocalizations {
  /// Creates a [TelebirrLocalizations] for the given [locale].
  ///
  /// An optional [customStrings] map can override any default translated
  /// string by its key (e.g. `'payNow'`, `'refund'`, etc.).
  TelebirrLocalizations(this.locale, [Map<String, String>? customStrings])
      : _customStrings = customStrings;

  /// The current locale for this localization instance.
  final Locale locale;

  final Map<String, String>? _customStrings;

  /// Returns the [TelebirrLocalizations] instance for the current widget tree.
  ///
  /// Must be called below a [Localizations] widget that includes
  /// [TelebirrLocalizationsDelegate].
  static TelebirrLocalizations of(BuildContext context) {
    return Localizations.of<TelebirrLocalizations>(
      context,
      TelebirrLocalizations,
    )!;
  }

  /// The default delegate for [TelebirrLocalizations].
  static const LocalizationsDelegate<TelebirrLocalizations> delegate =
      _TelebirrLocalizationsDelegate();

  /// Whether the current locale uses right-to-left text direction.
  bool get isRtl => locale.languageCode == 'ar';

  Map<String, String> get _strings {
    final app = AppLocalizations(locale);
    return {
      'payNow': app.payNow,
      'processing': app.processing,
      'testMode': app.testMode,
      'statusSuccess': app.statusSuccess,
      'statusFail': app.statusFail,
      'statusTimeout': app.statusTimeout,
      'statusPending': app.statusPending,
      'statusAccepted': app.statusAccepted,
      'statusRefunding': app.statusRefunding,
      'statusRefundSuccess': app.statusRefundSuccess,
      'statusRefundFailed': app.statusRefundFailed,
      'refund': app.refund,
      'refundConfirm': app.refundConfirm,
      'refundProcessing': app.refundProcessing,
      'refundSuccess': app.refundSuccess,
      'refundFailed': app.refundFailed,
      'retry': app.retry,
      'retryCountdown': app.retryCountdown,
      'retryFailed': app.retryFailed,
      'errorGeneric': app.errorGeneric,
      'errorNetwork': app.errorNetwork,
      'errorTimeout': app.errorTimeout,
      'errorAuth': app.errorAuth,
      'errorValidation': app.errorValidation,
      'errorDismiss': app.errorDismiss,
      'webhookVerificationFailed': app.webhookVerificationFailed,
      ...?_customStrings,
    };
  }

  /// The label for the primary payment action button.
  String get payNow => _strings['payNow'] ?? 'Pay Now';

  /// A generic "processing" indicator label.
  String get processing => _strings['processing'] ?? 'Processing...';

  /// The label shown on the sandbox environment badge.
  String get testMode => _strings['testMode'] ?? 'Test Mode';

  /// Status label for a successful payment.
  String get statusSuccess => _strings['statusSuccess'] ?? 'Success';

  /// Status label for a failed payment.
  String get statusFail => _strings['statusFail'] ?? 'Failed';

  /// Status label for a timed-out order.
  String get statusTimeout => _strings['statusTimeout'] ?? 'Timed Out';

  /// Status label for a payment awaiting completion.
  String get statusPending => _strings['statusPending'] ?? 'Pending';

  /// Status label for an order that has been accepted.
  String get statusAccepted => _strings['statusAccepted'] ?? 'Accepted';

  /// Status label for an order currently being refunded.
  String get statusRefunding => _strings['statusRefunding'] ?? 'Refunding';

  /// Status label for a successfully refunded order.
  String get statusRefundSuccess =>
      _strings['statusRefundSuccess'] ?? 'Refund Success';

  /// Status label for a failed refund.
  String get statusRefundFailed =>
      _strings['statusRefundFailed'] ?? 'Refund Failed';

  /// The label for refund-related actions.
  String get refund => _strings['refund'] ?? 'Refund';

  /// The confirmation prompt shown before submitting a refund.
  String get refundConfirm =>
      _strings['refundConfirm'] ?? 'Are you sure you want to refund this order?';

  /// A label indicating a refund is being processed.
  String get refundProcessing =>
      _strings['refundProcessing'] ?? 'Processing refund...';

  /// The label shown after a successful refund.
  String get refundSuccess =>
      _strings['refundSuccess'] ?? 'Refund successful';

  /// The label shown when a refund fails.
  String get refundFailed => _strings['refundFailed'] ?? 'Refund failed';

  /// The label for the retry action button.
  String get retry => _strings['retry'] ?? 'Retry';

  /// A countdown label for automatic retries (use `{seconds}` as placeholder).
  String get retryCountdown =>
      _strings['retryCountdown'] ?? 'Retrying in {seconds}s...';

  /// The label shown when all retry attempts have been exhausted.
  String get retryFailed => _strings['retryFailed'] ?? 'Retry failed';

  /// A generic error message.
  String get errorGeneric =>
      _strings['errorGeneric'] ?? 'An error occurred';

  /// An error message indicating a network connectivity issue.
  String get errorNetwork => _strings['errorNetwork'] ?? 'Network error';

  /// An error message indicating the request timed out.
  String get errorTimeout =>
      _strings['errorTimeout'] ?? 'Request timed out';

  /// An error message indicating an authentication failure.
  String get errorAuth =>
      _strings['errorAuth'] ?? 'Authentication failed';

  /// An error message indicating a validation failure.
  String get errorValidation =>
      _strings['errorValidation'] ?? 'Validation error';

  /// The tooltip text for the error dismiss (close) button.
  String get errorDismiss => _strings['errorDismiss'] ?? 'Dismiss';

  /// An error message indicating webhook signature verification failed.
  String get webhookVerificationFailed =>
      _strings['webhookVerificationFailed'] ?? 'Webhook verification failed';

  /// Returns the localized label for a given [status] string key.
  ///
  /// Recognized keys: `SUCCESS`, `FAIL`, `TIMEOUT`, `PENDING`, `ACCEPTED`,
  /// `REFUNDING`, `REFUND_SUCCESS`, `REFUND_FAILED`.
  /// Returns the raw [status] string for unrecognized keys.
  String statusLabel(String status) {
    return switch (status) {
      'SUCCESS' => statusSuccess,
      'FAIL' => statusFail,
      'TIMEOUT' => statusTimeout,
      'PENDING' => statusPending,
      'ACCEPTED' => statusAccepted,
      'REFUNDING' => statusRefunding,
      'REFUND_SUCCESS' => statusRefundSuccess,
      'REFUND_FAILED' => statusRefundFailed,
      _ => status,
    };
  }
}

class _TelebirrLocalizationsDelegate
    extends LocalizationsDelegate<TelebirrLocalizations> {
  const _TelebirrLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<TelebirrLocalizations> load(Locale locale) async {
    return TelebirrLocalizations(locale);
  }

  @override
  bool shouldReload(_TelebirrLocalizationsDelegate old) => false;
}

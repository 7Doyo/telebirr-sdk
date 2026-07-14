import 'package:flutter/widgets.dart';

import '../../l10n/strings_en.dart';
import '../../l10n/strings_am.dart';
import '../../l10n/strings_om.dart';
import '../../l10n/strings_ti.dart';
import '../../l10n/strings_ar.dart';

/// ARB-generated localizations class for the Telebirr SDK.
///
/// This class is equivalent to what `flutter gen-l10n` produces from the
/// ARB files in `lib/l10n/`. Translations are embedded for zero-file I/O.
/// Supports English, Amharic, Oromo, Tigrinya, and Arabic locales.
class AppLocalizations {
  /// Creates an [AppLocalizations] instance for the given [locale].
  AppLocalizations(this.locale);

  /// The locale this localization instance resolves strings for.
  final Locale locale;

  /// Returns the [AppLocalizations] instance for the current widget tree.
  ///
  /// Must be called below a [Localizations] widget that includes
  /// [AppLocalizations.delegate].
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// The delegate for loading [AppLocalizations] instances.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A convenience list containing only [delegate], suitable for passing
  /// directly to `MaterialApp.localizationsDelegates`.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
  ];

  /// The list of locales supported by this SDK.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('am'),
    Locale('om'),
    Locale('ti'),
    Locale('ar'),
  ];

  static const Map<String, Map<String, String>> _strings = {
    'en': telebirrStringsEn,
    'am': telebirrStringsAm,
    'om': telebirrStringsOm,
    'ti': telebirrStringsTi,
    'ar': telebirrStringsAr,
  };

  Map<String, String> get _currentStrings =>
      _strings[locale.languageCode] ?? _strings['en']!;

  /// The label for the primary payment action button.
  String get payNow => _currentStrings['payNow'] ?? 'Pay Now';

  /// A generic "processing" indicator label.
  String get processing => _currentStrings['processing'] ?? 'Processing...';

  /// The label shown on the sandbox environment badge.
  String get testMode => _currentStrings['testMode'] ?? 'Test Mode';

  /// Status label for a successful payment.
  String get statusSuccess =>
      _currentStrings['statusSuccess'] ?? 'Success';

  /// Status label for a failed payment.
  String get statusFail => _currentStrings['statusFail'] ?? 'Failed';

  /// Status label for a timed-out order.
  String get statusTimeout =>
      _currentStrings['statusTimeout'] ?? 'Timed Out';

  /// Status label for a payment awaiting completion.
  String get statusPending =>
      _currentStrings['statusPending'] ?? 'Pending';

  /// Status label for an order that has been accepted.
  String get statusAccepted =>
      _currentStrings['statusAccepted'] ?? 'Accepted';

  /// Status label for an order currently being refunded.
  String get statusRefunding =>
      _currentStrings['statusRefunding'] ?? 'Refunding';

  /// Status label for a successfully refunded order.
  String get statusRefundSuccess =>
      _currentStrings['statusRefundSuccess'] ?? 'Refund Success';

  /// Status label for a failed refund.
  String get statusRefundFailed =>
      _currentStrings['statusRefundFailed'] ?? 'Refund Failed';

  /// The label for refund-related actions.
  String get refund => _currentStrings['refund'] ?? 'Refund';

  /// The confirmation prompt shown before submitting a refund.
  String get refundConfirm =>
      _currentStrings['refundConfirm'] ?? 'Are you sure you want to refund this order?';

  /// A label indicating a refund is being processed.
  String get refundProcessing =>
      _currentStrings['refundProcessing'] ?? 'Processing refund...';

  /// The label shown after a successful refund.
  String get refundSuccess =>
      _currentStrings['refundSuccess'] ?? 'Refund successful';

  /// The label shown when a refund fails.
  String get refundFailed =>
      _currentStrings['refundFailed'] ?? 'Refund failed';

  /// The label for the retry action button.
  String get retry => _currentStrings['retry'] ?? 'Retry';

  /// A countdown label for automatic retries (use `{seconds}` as placeholder).
  String get retryCountdown =>
      _currentStrings['retryCountdown'] ?? 'Retrying in {seconds}s...';

  /// The label shown when all retry attempts have been exhausted.
  String get retryFailed => _currentStrings['retryFailed'] ?? 'Retry failed';

  /// A generic error message.
  String get errorGeneric =>
      _currentStrings['errorGeneric'] ?? 'An error occurred';

  /// An error message indicating a network connectivity issue.
  String get errorNetwork =>
      _currentStrings['errorNetwork'] ?? 'Network error';

  /// An error message indicating the request timed out.
  String get errorTimeout =>
      _currentStrings['errorTimeout'] ?? 'Request timed out';

  /// An error message indicating an authentication failure.
  String get errorAuth =>
      _currentStrings['errorAuth'] ?? 'Authentication failed';

  /// An error message indicating a validation failure.
  String get errorValidation =>
      _currentStrings['errorValidation'] ?? 'Validation error';

  /// The tooltip text for the error dismiss (close) button.
  String get errorDismiss => _currentStrings['errorDismiss'] ?? 'Dismiss';

  /// An error message indicating webhook signature verification failed.
  String get webhookVerificationFailed =>
      _currentStrings['webhookVerificationFailed'] ?? 'Webhook verification failed';
}

/// Localizations delegate that loads [AppLocalizations] for supported locales.
///
/// Supports English (`en`), Amharic (`am`), Oromo (`om`), Tigrinya (`ti`),
/// and Arabic (`ar`). Falls back to English for unsupported locales.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am', 'om', 'ti', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

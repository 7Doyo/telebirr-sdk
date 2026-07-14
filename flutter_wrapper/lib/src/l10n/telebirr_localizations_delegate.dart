import 'package:flutter/widgets.dart';

import 'telebirr_localizations.dart';

/// Public delegate for use in `MaterialApp` `localizationsDelegates`.
///
/// This delegates to [TelebirrLocalizations] and supports optional
/// custom translations override via [customTranslations].
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     TelebirrLocalizationsDelegate(
///       customTranslations: {
///         'en': {'payNow': 'Proceed to Payment'},
///       },
///     ),
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///   ],
///   // ...
/// )
/// ```
class TelebirrLocalizationsDelegate
    extends LocalizationsDelegate<TelebirrLocalizations> {
  /// Optional map of locale code to custom string overrides.
  ///
  /// The outer key is the language code (e.g. `'en'`, `'am'`).
  /// The inner map overrides individual string keys (e.g. `'payNow'`).
  final Map<String, Map<String, String>>? customTranslations;

  /// Creates a [TelebirrLocalizationsDelegate].
  ///
  /// If [customTranslations] is provided, matching keys are merged on top
  /// of the default translated strings for the current locale.
  const TelebirrLocalizationsDelegate({this.customTranslations});

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<TelebirrLocalizations> load(Locale locale) async {
    return TelebirrLocalizations(
      locale,
      customTranslations?[locale.languageCode],
    );
  }

  @override
  bool shouldReload(TelebirrLocalizationsDelegate old) => false;
}

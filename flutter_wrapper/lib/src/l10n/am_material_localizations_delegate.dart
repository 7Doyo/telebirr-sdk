import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'am_material_localizations.dart';

class AmMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const AmMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'am';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());

    return SynchronousFuture<MaterialLocalizations>(
      AmMaterialLocalizations(
        localeName: localeName,
        decimalFormat: intl.NumberFormat('#,##0.###', 'en_US'),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'en_US'),
        fullYearFormat: intl.DateFormat('y', 'en'),
        compactDateFormat: intl.DateFormat('yMd', 'en'),
        shortDateFormat: intl.DateFormat('yMMMd', 'en'),
        mediumDateFormat: intl.DateFormat('EEE, MMM d', 'en'),
        longDateFormat: intl.DateFormat('EEEE, MMMM d, y', 'en'),
        yearMonthFormat: intl.DateFormat('MMMM y', 'en'),
        shortMonthDayFormat: intl.DateFormat('MMM d'),
      ),
    );
  }

  @override
  bool shouldReload(AmMaterialLocalizationsDelegate old) => false;
}

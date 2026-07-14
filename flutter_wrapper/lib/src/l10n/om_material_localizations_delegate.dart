import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'om_material_localizations.dart';

class OmMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const OmMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());

    return SynchronousFuture<MaterialLocalizations>(
      OmMaterialLocalizations(
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
  bool shouldReload(OmMaterialLocalizationsDelegate old) => false;
}

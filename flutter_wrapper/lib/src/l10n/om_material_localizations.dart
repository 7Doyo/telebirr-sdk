import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class OmMaterialLocalizations extends GlobalMaterialLocalizations {
  const OmMaterialLocalizations({
    required super.localeName,
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  @override
  String get openAppDrawerTooltip => 'Open navigation menu';
  @override
  String get backButtonTooltip => 'Dubbi';
  @override
  String get clearButtonTooltip => 'Clear';
  @override
  String get closeButtonTooltip => 'Close';
  @override
  String get deleteButtonTooltip => 'Delete';
  @override
  String get moreButtonTooltip => 'Dabalataa';
  @override
  String get nextMonthTooltip => 'Next month';
  @override
  String get previousMonthTooltip => 'Previous month';
  @override
  String get firstPageTooltip => 'First page';
  @override
  String get lastPageTooltip => 'Last page';
  @override
  String get nextPageTooltip => 'Next page';
  @override
  String get previousPageTooltip => 'Previous page';
  @override
  String get showMenuTooltip => 'Show menu';

  @override
  String get cancelButtonLabel => 'Haqi';
  @override
  String get closeButtonLabel => 'Cufi';
  @override
  String get continueButtonLabel => 'Itti fufi';
  @override
  String get copyButtonLabel => 'Copii';
  @override
  String get cutButtonLabel => 'Muri';
  @override
  String get scanTextButtonLabel => 'Barruu siiq';
  @override
  String get okButtonLabel => 'OK';
  @override
  String get pasteButtonLabel => 'Masaki';
  @override
  String get selectAllButtonLabel => 'Hunda filadhu';
  @override
  String get lookUpButtonLabel => 'Illii';
  @override
  String get searchWebButtonLabel => 'Intarneetii barbaadi';
  @override
  String get shareButtonLabel => 'Qoodhu';
  @override
  String get viewLicensesButtonLabel => 'Laasensii ilaali';
  @override
  String get saveButtonLabel => 'Olkaa\'i';

  @override
  String get anteMeridiemAbbreviation => 'WD';
  @override
  String get postMeridiemAbbreviation => 'WB';
  @override
  String get timePickerHourModeAnnouncement => 'Sa\'aati filadhu';
  @override
  String get timePickerMinuteModeAnnouncement => 'Daqiiqaawaa filadhu';
  @override
  String get timePickerDialHelpText => 'Wakati filadhu';
  @override
  String get timePickerInputHelpText => 'Wakati naqnaa galchuu';
  @override
  String get timePickerHourLabel => 'Sa\'aa';
  @override
  String get timePickerMinuteLabel => 'Daqiiqaawaa';
  @override
  String get dialModeButtonLabel => 'Gara waraa jijjiiri';
  @override
  String get inputTimeModeButtonLabel => 'Gara naqnaatti jijjiiri';
  @override
  String get calendarModeButtonLabel => 'Gara herrega guyyaa jijjiiri';
  @override
  String get inputDateModeButtonLabel => 'Gara naqnaa barruu jijjiiri';

  @override
  String get modalBarrierDismissLabel => 'Gaggeessi';
  @override
  String get menuDismissLabel => 'Baasuu';
  @override
  String get drawerLabel => 'Meeshaa';
  @override
  String get popupMenuLabel => 'Meeshaaixi';
  @override
  String get menuBarMenuLabel => 'Meeshaaboo';
  @override
  String get dialogLabel => 'Qaaqa';
  @override
  String get alertDialogLabel => 'Akeekkachiisuu';
  @override
  String get searchFieldLabel => 'Barbaadi';
  @override
  String get currentDateLabel => 'Barruu ammaa';
  @override
  String get selectedDateLabel => 'Barruu filatame';
  @override
  String get scrimLabel => 'Scrim';
  @override
  String get bottomSheetLabel => 'Waraabbii';
  @override
  String get signedInLabel => 'Seenaame';
  @override
  String get hideAccountsLabel => 'Herrega dhoksi';
  @override
  String get showAccountsLabel => 'Herrega mul\'isi';
  String get passwordsFieldLabel => 'Jecha sirrii';

  @override
  String get dateSeparator => '/';
  @override
  String get dateHelpText => 'Barruu galchuu';
  @override
  String get selectYearSemanticsLabel => 'Waraacha filadhu';
  @override
  String get unspecifiedDate => 'Barruu hin';
  @override
  String get unspecifiedDateRange => 'Barruu dabballoo hin';
  @override
  String get dateInputLabel => 'Barruu naqnaa';
  @override
  String get dateRangeStartLabel => 'Barruu eegala';
  @override
  String get dateRangeEndLabel => 'Barruu dhuma';
  @override
  String get invalidDateFormatLabel => 'Barruu sirrii hin';
  @override
  String get invalidDateRangeLabel => 'Barruu dabballoo sirrii hin';
  @override
  String get dateOutOfRangeLabel => 'Barruu gamootaa';
  @override
  String get datePickerHelpText => 'Barruu filadhu';
  @override
  String get dateRangePickerHelpText => 'Barruu dabballoo filadhu';
  @override
  String get invalidTimeLabel => 'Wakat sirrii hin';

  @override
  String get aboutListTileTitleRaw => r'Waaqayoo $applicationName';
  @override
  String get scrimOnTapHintRaw => r'$modalRouteContentName gaggeessi';
  @override
  String get tabLabelRaw => r'Tabbitii $tabIndex/$tabCount';
  @override
  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow keessa $rowCount';
  @override
  String get pageRowsInfoTitleApproximateRaw =>
      r'$firstRow–$lastRow keessa ~$rowCount';
  @override
  String get dateRangeStartDateSemanticLabelRaw =>
      r'Barruu eegala $formattedDate';
  @override
  String get dateRangeEndDateSemanticLabelRaw => r'Barruu dhuma $fullDate';
  @override
  String get licensesPackageDetailTextOther => r'$licenseCount laasensii';

  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount filatame';
  @override
  String? get selectedRowCountTitleZero => null;
  @override
  String? get selectedRowCountTitleOne => null;
  @override
  String? get selectedRowCountTitleTwo => null;
  @override
  String? get selectedRowCountTitleFew => null;
  @override
  String? get selectedRowCountTitleMany => null;
  @override
  String? get licensesPackageDetailTextZero => null;
  @override
  String? get licensesPackageDetailTextOne => null;
  @override
  String? get licensesPackageDetailTextTwo => null;
  @override
  String? get licensesPackageDetailTextFew => null;
  @override
  String? get licensesPackageDetailTextMany => null;
  @override
  String get remainingTextFieldCharacterCountOther =>
      r'$remaining qabduu haguu';
  @override
  String? get remainingTextFieldCharacterCountZero => null;
  @override
  String? get remainingTextFieldCharacterCountOne => null;
  @override
  String? get remainingTextFieldCharacterCountTwo => null;
  @override
  String? get remainingTextFieldCharacterCountFew => null;
  @override
  String? get remainingTextFieldCharacterCountMany => null;

  @override
  String get keyboardKeyAlt => 'Alt';
  @override
  String get keyboardKeyAltGraph => 'AltGr';
  @override
  String get keyboardKeyBackspace => 'Backspace';
  @override
  String get keyboardKeyCapsLock => 'Caps Lock';
  @override
  String get keyboardKeyChannelDown => 'Channel Down';
  @override
  String get keyboardKeyChannelUp => 'Channel Up';
  @override
  String get keyboardKeyControl => 'Control';
  @override
  String get keyboardKeyDelete => 'Delete';
  @override
  String get keyboardKeyEject => 'Eject';
  @override
  String get keyboardKeyEnd => 'End';
  @override
  String get keyboardKeyEscape => 'Escape';
  @override
  String get keyboardKeyFn => 'Fn';
  @override
  String get keyboardKeyHome => 'Home';
  @override
  String get keyboardKeyInsert => 'Insert';
  @override
  String get keyboardKeyMeta => 'Meta';
  @override
  String get keyboardKeyMetaMacOs => 'Command';
  @override
  String get keyboardKeyMetaWindows => 'Win';
  @override
  String get keyboardKeyNumLock => 'Num Lock';
  @override
  String get keyboardKeyNumpad0 => 'Num 0';
  @override
  String get keyboardKeyNumpad1 => 'Num 1';
  @override
  String get keyboardKeyNumpad2 => 'Num 2';
  @override
  String get keyboardKeyNumpad3 => 'Num 3';
  @override
  String get keyboardKeyNumpad4 => 'Num 4';
  @override
  String get keyboardKeyNumpad5 => 'Num 5';
  @override
  String get keyboardKeyNumpad6 => 'Num 6';
  @override
  String get keyboardKeyNumpad7 => 'Num 7';
  @override
  String get keyboardKeyNumpad8 => 'Num 8';
  @override
  String get keyboardKeyNumpad9 => 'Num 9';
  @override
  String get keyboardKeyNumpadAdd => 'Num +';
  @override
  String get keyboardKeyNumpadComma => 'Num ,';
  @override
  String get keyboardKeyNumpadDecimal => 'Num .';
  @override
  String get keyboardKeyNumpadDivide => 'Num /';
  @override
  String get keyboardKeyNumpadEnter => 'Num Enter';
  @override
  String get keyboardKeyNumpadEqual => 'Num =';
  @override
  String get keyboardKeyNumpadMultiply => 'Num *';
  @override
  String get keyboardKeyNumpadParenLeft => 'Num (';
  @override
  String get keyboardKeyNumpadParenRight => 'Num )';
  @override
  String get keyboardKeyNumpadSubtract => 'Num -';
  @override
  String get keyboardKeyPageDown => 'Page Down';
  @override
  String get keyboardKeyPageUp => 'Page Up';
  @override
  String get keyboardKeyPower => 'Power';
  @override
  String get keyboardKeyPowerOff => 'Power Off';
  @override
  String get keyboardKeyPrintScreen => 'Print Screen';
  @override
  String get keyboardKeyScrollLock => 'Scroll Lock';
  @override
  String get keyboardKeySelect => 'Select';
  @override
  String get keyboardKeyShift => 'Shift';
  @override
  String get keyboardKeySpace => 'Space';

  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;
  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.HH_colon_mm;

  @override
  String get licensesPageTitle => 'Laasensii';
  @override
  String get rowsPerPageTitle => 'Kabiroonii rows:';
  @override
  String get refreshIndicatorSemanticLabel => 'Haaromsi';
  @override
  String get reorderItemToStart => 'Gara jalqabatti ergi';
  @override
  String get reorderItemToEnd => 'Gara dhumaatti ergi';
  @override
  String get reorderItemUp => 'Gara alaatti ergi';
  @override
  String get reorderItemDown => 'Gara gadaatti ergi';
  @override
  String get reorderItemLeft => 'Gara bitaatti ergi';
  @override
  String get reorderItemRight => 'Gara mirgaatti ergi';
  @override
  String get collapsedHint => 'Balleesse';
  @override
  String get expandedHint => 'Cufame';
  @override
  String get collapsedIconTapHint => 'Balleessuu';
  @override
  String get expandedIconTapHint => 'Cufuu';
  @override
  String get expansionTileCollapsedHint => 'Balleessuu';
  @override
  String get expansionTileCollapsedTapHint => 'Dabalataa ilaali';
  @override
  String get expansionTileExpandedHint => 'Cufuu';
  @override
  String get expansionTileExpandedTapHint => 'Cufuu';
}

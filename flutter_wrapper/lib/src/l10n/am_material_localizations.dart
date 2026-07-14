import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

class AmMaterialLocalizations extends GlobalMaterialLocalizations {
  const AmMaterialLocalizations({
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

  AmMaterialLocalizations.raw()
      : super(
          localeName: 'am',
          fullYearFormat: intl.DateFormat('y', 'am'),
          compactDateFormat: intl.DateFormat('yMd', 'am'),
          shortDateFormat: intl.DateFormat('yMMMd', 'am'),
          mediumDateFormat: intl.DateFormat('EEE, MMM d', 'am'),
          longDateFormat: intl.DateFormat('EEEE, MMMM d, y', 'am'),
          yearMonthFormat: intl.DateFormat('MMMM y', 'am'),
          shortMonthDayFormat: intl.DateFormat('MMM d', 'am'),
          decimalFormat: intl.NumberFormat('#,##0.###', 'am'),
          twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'am'),
        );

  @override
  String get openAppDrawerTooltip => 'የመ.heading ዝርዝር ክፈት';
  @override
  String get backButtonTooltip => 'ወደ ኋላ ተመለስ';
  @override
  String get clearButtonTooltip => 'አጽዳ';
  @override
  String get closeButtonTooltip => 'ዝጋግ';
  @override
  String get deleteButtonTooltip => 'ሰርዝ';
  @override
  String get moreButtonTooltip => 'ተጨማሪ';
  @override
  String get nextMonthTooltip => 'ቀጣይ ወር';
  @override
  String get previousMonthTooltip => 'ያለፈው ወር';
  @override
  String get firstPageTooltip => 'የመጀመሪያ ገጽ';
  @override
  String get lastPageTooltip => 'የመጨረሻ ገጽ';
  @override
  String get nextPageTooltip => 'ቀጣይ ገጽ';
  @override
  String get previousPageTooltip => 'ያለፈው ገጽ';
  @override
  String get showMenuTooltip => 'ዝርዝር አሳይ';

  @override
  String get cancelButtonLabel => 'ሰርዝ';
  @override
  String get closeButtonLabel => 'ዝጋግ';
  @override
  String get continueButtonLabel => 'ቀጥል';
  @override
  String get copyButtonLabel => 'ቅዳ';
  @override
  String get cutButtonLabel => 'ቀንጥል';
  @override
  String get scanTextButtonLabel => 'ጽሑፍ በልጽ';
  @override
  String get okButtonLabel => 'እሺ';
  @override
  String get pasteButtonLabel => 'ለጥፍ';
  @override
  String get selectAllButtonLabel => 'ሁሉንም ምረጥ';
  @override
  String get lookUpButtonLabel => 'ወደ ላይ ተመልከት';
  @override
  String get searchWebButtonLabel => 'በኢንተርኔት ፈልግ';
  @override
  String get shareButtonLabel => 'አካፍል';
  @override
  String get viewLicensesButtonLabel => 'ፍቃዶች ይመልከቱ';
  @override
  String get saveButtonLabel => 'አስቀምጥ';

  @override
  String get anteMeridiemAbbreviation => 'ጥዋት';
  @override
  String get postMeridiemAbbreviation => 'ከሰዓት በኋላ';
  @override
  String get timePickerHourModeAnnouncement => 'ሰዓት ምረጥ';
  @override
  String get timePickerMinuteModeAnnouncement => 'ደቂቃ ምረጥ';
  @override
  String get timePickerDialHelpText => 'ሰዓት ምረጥ';
  @override
  String get timePickerInputHelpText => 'ሰዓት ያስገቡ';
  @override
  String get timePickerHourLabel => 'ሰዓት';
  @override
  String get timePickerMinuteLabel => 'ደቂቃ';
  @override
  String get dialModeButtonLabel => 'ወደ ዲያል ሁነታ ቀይር';
  @override
  String get inputTimeModeButtonLabel => 'ወደ አስገባኛ ሁነታ ቀይር';
  @override
  String get calendarModeButtonLabel => 'ወደ ቀን ሰንጠረዥ ሁነታ ቀይር';
  @override
  String get inputDateModeButtonLabel => 'ወደ አስገባኛ ቀን ሁነታ ቀይር';

  @override
  String get modalBarrierDismissLabel => 'ዝጋግ';
  @override
  String get menuDismissLabel => 'ዝርዝር ዘጋ';
  @override
  String get drawerLabel => 'የመ绘画 ማስከበኛ';
  @override
  String get popupMenuLabel => '/popper ዝርዝር';
  @override
  String get menuBarMenuLabel => 'የምልክት ሰንጠረዥ ዝርዝር';
  @override
  String get dialogLabel => 'ውይይት';
  @override
  String get alertDialogLabel => 'ማንቂያ';
  @override
  String get searchFieldLabel => 'ፈልግ';
  @override
  String get currentDateLabel => 'የዛሬ ቀን';
  @override
  String get selectedDateLabel => 'የተመረጠው ቀን';
  @override
  String get scrimLabel => 'ስክሪም';
  @override
  String get bottomSheetLabel => 'ታች ሉ为抓';
  @override
  String get signedInLabel => 'ተመዝግበዋል';
  @override
  String get hideAccountsLabel => 'שבון ዘጋ';
  @override
  String get showAccountsLabel => 'שבון አሳይ';
  String get passwordsFieldLabel => 'የይለፍ ቃል';

  @override
  String get dateSeparator => '/';
  @override
  String get dateHelpText => 'ቀን ያስገቡ';
  @override
  String get selectYearSemanticsLabel => 'ዓመት ምረጥ';
  @override
  String get unspecifiedDate => 'ቀን አልተወሰነም';
  @override
  String get unspecifiedDateRange => 'የቀን ክልል አልተወሰነም';
  @override
  String get dateInputLabel => 'ቀን ያስገቡ';
  @override
  String get dateRangeStartLabel => 'የመጀመሪያ ቀን';
  @override
  String get dateRangeEndLabel => 'የመጨረሻ ቀን';
  @override
  String get invalidDateFormatLabel => 'ቀን ትክክል አይደለም';
  @override
  String get invalidDateRangeLabel => 'የቀን ክልል ትክክል አይደለም';
  @override
  String get dateOutOfRangeLabel => 'ቀን ከተወሰነው ጋር ውጪ ነው';
  @override
  String get datePickerHelpText => 'ቀን ምረጥ';
  @override
  String get dateRangePickerHelpText => 'የቀን ክልል ምረጥ';
  @override
  String get invalidTimeLabel => 'ሰዓት ትክክል አይደለም';

  @override
  String get aboutListTileTitleRaw => r'ስለ $applicationName';
  @override
  String get scrimOnTapHintRaw => r'$modalRouteContentName ዘጋ';
  @override
  String get tabLabelRaw => r'Tab $tabIndex/$tabCount';
  @override
  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow ከ $rowCount ውስጥ';
  @override
  String get pageRowsInfoTitleApproximateRaw =>
      r'$firstRow–$lastRow ከ ~$rowCount ውስጥ';
  @override
  String get dateRangeStartDateSemanticLabelRaw => r'የመጀመሪያ ቀን $formattedDate';
  @override
  String get dateRangeEndDateSemanticLabelRaw => r'የመጨረሻ ቀን $fullDate';
  @override
  String get licensesPackageDetailTextOther => r'$licenseCount ፍቃድ';

  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount ተመርጧል';
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
  String get remainingTextFieldCharacterCountOther => r'$remaining ቃላት ቀርተዋል';
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
  String get keyboardKeyChannelDown => 'ቻናል ዝቅተኛ';
  @override
  String get keyboardKeyChannelUp => 'ቻናል ከፍተኛ';
  @override
  String get keyboardKeyControl => 'Control';
  @override
  String get keyboardKeyDelete => 'Delete';
  @override
  String get keyboardKeyEject => 'Eject';
  @override
  String get keyboardKeyEnd => 'መጨረሻ';
  @override
  String get keyboardKeyEscape => 'Escape';
  @override
  String get keyboardKeyFn => 'Fn';
  @override
  String get keyboardKeyHome => 'መነሻ';
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
  String get keyboardKeySelect => 'ምረጥ';
  @override
  String get keyboardKeyShift => 'Shift';
  @override
  String get keyboardKeySpace => 'Space';

  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;
  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.HH_colon_mm;

  @override
  String get licensesPageTitle => 'ፍቃዶች';
  @override
  String get rowsPerPageTitle => 'በገጽ ላይ ረድፍ:';
  @override
  String get refreshIndicatorSemanticLabel => 'አድስ';
  @override
  String get reorderItemToStart => 'ወደ መነሻ ቀይር';
  @override
  String get reorderItemToEnd => 'ወደ መጨረሻ ቀይር';
  @override
  String get reorderItemUp => 'ወደ ላይ ቀይር';
  @override
  String get reorderItemDown => 'ወደ ታች ቀይር';
  @override
  String get reorderItemLeft => 'ወደ ግራ ቀይር';
  @override
  String get reorderItemRight => 'ወደ ቀኝ ቀይር';
  @override
  String get collapsedHint => 'ጠቅልሎ';
  @override
  String get expandedHint => 'ሰፋ';
  @override
  String get collapsedIconTapHint => 'ጠቅልሎ ክፈት';
  @override
  String get expandedIconTapHint => 'ሰፋ ጠቅልል';
  @override
  String get expansionTileCollapsedHint => 'ጠቅልሎ';
  @override
  String get expansionTileCollapsedTapHint => 'ተጨማሪ ዝርዝር ለመጨመር ጠቅ አድርግ';
  @override
  String get expansionTileExpandedHint => 'ሰፋ';
  @override
  String get expansionTileExpandedTapHint => 'ዝርዝር ጠቅልል';
}

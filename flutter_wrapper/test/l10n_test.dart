import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

void main() {
  group('TelebirrLocalizations', () {
    test('English strings are correct', () {
      final l10n = TelebirrLocalizations(const Locale('en'));
      expect(l10n.payNow, 'Pay Now');
      expect(l10n.processing, 'Processing...');
      expect(l10n.testMode, 'Test Mode');
      expect(l10n.statusSuccess, 'Success');
      expect(l10n.statusFail, 'Failed');
      expect(l10n.statusTimeout, 'Timed Out');
      expect(l10n.statusPending, 'Pending');
    });

    test('Amharic strings are correct', () {
      final l10n = TelebirrLocalizations(const Locale('am'));
      expect(l10n.payNow, 'አሁን ይክፈሉ');
      expect(l10n.testMode, 'የምርምር ሁኔታ');
    });

    test('Afaan Oromo strings are correct', () {
      final l10n = TelebirrLocalizations(const Locale('om'));
      expect(l10n.payNow, 'Amma Kufi');
      expect(l10n.testMode, 'Haala Waliigaltee');
    });

    test('Tigrinya strings are correct', () {
      final l10n = TelebirrLocalizations(const Locale('ti'));
      expect(l10n.payNow, 'ሕጂ ይክፈሉ');
      expect(l10n.testMode, 'ኩነት ምርመራ');
    });

    test('Arabic strings are correct', () {
      final l10n = TelebirrLocalizations(const Locale('ar'));
      expect(l10n.payNow, 'ادفع الآن');
      expect(l10n.testMode, 'وضع الاختبار');
    });

    test('falls back to English for unknown locale', () {
      final l10n = TelebirrLocalizations(const Locale('fr'));
      expect(l10n.payNow, 'Pay Now');
      expect(l10n.testMode, 'Test Mode');
    });

    test('custom strings override built-in', () {
      final l10n = TelebirrLocalizations(
        const Locale('en'),
        {'payNow': 'Custom Pay'},
      );
      expect(l10n.payNow, 'Custom Pay');
      expect(l10n.processing, 'Processing...');
    });

    test('statusLabel returns correct labels', () {
      final l10n = TelebirrLocalizations(const Locale('en'));
      expect(l10n.statusLabel('SUCCESS'), 'Success');
      expect(l10n.statusLabel('FAIL'), 'Failed');
      expect(l10n.statusLabel('TIMEOUT'), 'Timed Out');
      expect(l10n.statusLabel('PENDING'), 'Pending');
      expect(l10n.statusLabel('UNKNOWN'), 'UNKNOWN');
    });

    test('statusLabel works with Amharic', () {
      final l10n = TelebirrLocalizations(const Locale('am'));
      expect(l10n.statusLabel('SUCCESS'), 'ተሳክቷል');
      expect(l10n.statusLabel('FAIL'), 'አልተሳካም');
    });
  });

  group('TelebirrLocalizationsDelegate', () {
    test('isSupported returns true for any locale', () {
      const delegate = TelebirrLocalizationsDelegate();
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('xx')), isTrue);
    });

    test('load returns TelebirrLocalizations for the given locale', () async {
      const delegate = TelebirrLocalizationsDelegate();
      final l10n = await delegate.load(const Locale('am'));
      expect(l10n.locale.languageCode, 'am');
      expect(l10n.payNow, 'አሁን ይክፈሉ');
    });
  });

  group('OmMaterialLocalizationsDelegate', () {
    test('isSupported returns true only for om', () {
      const delegate = OmMaterialLocalizationsDelegate();
      expect(delegate.isSupported(const Locale('om')), isTrue);
      expect(delegate.isSupported(const Locale('ti')), isFalse);
      expect(delegate.isSupported(const Locale('en')), isFalse);
      expect(delegate.isSupported(const Locale('am')), isFalse);
    });
  });

  group('TiMaterialLocalizationsDelegate', () {
    test('isSupported returns true only for ti', () {
      const delegate = TiMaterialLocalizationsDelegate();
      expect(delegate.isSupported(const Locale('ti')), isTrue);
      expect(delegate.isSupported(const Locale('om')), isFalse);
      expect(delegate.isSupported(const Locale('en')), isFalse);
      expect(delegate.isSupported(const Locale('am')), isFalse);
    });
  });
}

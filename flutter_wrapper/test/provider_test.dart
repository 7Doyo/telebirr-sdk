import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

void main() {
  group('TelebirrProvider', () {
    testWidgets('provides Telebirr instance to descendants', (tester) async {
      late Telebirr captured;
      const config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: 'test_app_id',
        merchantAppId: 'test_merchant_id',
        merchantCode: 'test_merchant_code',
        appSecret: 'sk_test_abc123',
        privateKeyPem: 'test_key',
        shortCode: '12345',
        timeout: '120',
        notifyUrl: 'https://example.com/notify',
      );
      final telebirr = Telebirr(config);

      await tester.pumpWidget(
        TelebirrProvider(
          telebirr: telebirr,
          child: Builder(
            builder: (context) {
              captured = context.telebirr;
              return const MaterialApp(home: SizedBox());
            },
          ),
        ),
      );

      expect(captured, same(telebirr));
    });

    testWidgets('of() throws when no provider exists', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => TelebirrProvider.of(context),
                throwsA(isA<AssertionError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('updateShouldNotify returns true when telebirr changes',
        (tester) async {
      const config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: 'test_app_id',
        merchantAppId: 'test_merchant_id',
        merchantCode: 'test_merchant_code',
        appSecret: 'sk_test_abc123',
        privateKeyPem: 'test_key',
        shortCode: '12345',
        timeout: '120',
        notifyUrl: 'https://example.com/notify',
      );
      final telebirr1 = Telebirr(config);
      final telebirr2 = Telebirr(config);

      final widget = TelebirrProvider(
        telebirr: telebirr1,
        child: const MaterialApp(home: SizedBox()),
      );

      expect(widget.updateShouldNotify(widget), isFalse);

      final widget2 = TelebirrProvider(
        telebirr: telebirr2,
        child: const MaterialApp(home: SizedBox()),
      );

      expect(widget.updateShouldNotify(widget2), isTrue);
    });
  });
}

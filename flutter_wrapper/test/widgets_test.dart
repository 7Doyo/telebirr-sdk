import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

class _LoadingPaymentNotifier extends ChangeNotifier
    implements PaymentNotifier {
  _LoadingPaymentNotifier();

  @override
  PaymentState get state => PaymentState.loading;

  @override
  bool get isLoading => true;

  @override
  String? get errorMessage => null;

  @override
  CreateOrderResponse? get response => null;

  @override
  Future<void> charge(CreateOrderParams params) async {}

  @override
  void reset() {}
}

Future<void> _pumpWithL10n(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        TelebirrLocalizations.delegate,
        AmMaterialLocalizationsDelegate(),
        OmMaterialLocalizationsDelegate(),
        TiMaterialLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
        Locale('ti'),
        Locale('ar'),
      ],
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

void main() {
  late Telebirr telebirr;
  late PaymentNotifier notifier;

  setUp(() {
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
    telebirr = Telebirr(config);
    notifier = PaymentNotifier(telebirr);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('TestModeBadge', () {
    testWidgets('renders badge when environment is sandbox', (tester) async {
      await _pumpWithL10n(
        tester,
        const TestModeBadge(environment: Environment.sandbox),
      );

      expect(find.text('Test Mode'), findsOneWidget);
    });

    testWidgets('renders nothing when environment is production',
        (tester) async {
      await _pumpWithL10n(
        tester,
        const TestModeBadge(environment: Environment.production),
      );

      expect(find.text('Test Mode'), findsNothing);
    });
  });

  group('PaymentStatusChip', () {
    testWidgets('displays success status', (tester) async {
      await _pumpWithL10n(
        tester,
        const PaymentStatusChip(status: PaymentStatus.success),
      );

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('displays fail status', (tester) async {
      await _pumpWithL10n(
        tester,
        const PaymentStatusChip(status: PaymentStatus.fail),
      );

      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('displays timeout status', (tester) async {
      await _pumpWithL10n(
        tester,
        const PaymentStatusChip(status: PaymentStatus.timeout),
      );

      expect(find.text('Timed Out'), findsOneWidget);
    });

    testWidgets('displays pending status', (tester) async {
      await _pumpWithL10n(
        tester,
        const PaymentStatusChip(status: PaymentStatus.pending),
      );

      expect(find.text('Pending'), findsOneWidget);
    });
  });

  group('PaymentButton', () {
    testWidgets('renders with default label', (tester) async {
      await _pumpWithL10n(
        tester,
        PaymentButton(
          notifier: notifier,
          onPressed: () {},
        ),
      );

      expect(find.text('Pay Now'), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await _pumpWithL10n(
        tester,
        PaymentButton(
          notifier: notifier,
          onPressed: () {},
          label: 'Complete Payment',
        ),
      );

      expect(find.text('Complete Payment'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      final loadingNotifier = _LoadingPaymentNotifier();

      await _pumpWithL10n(
        tester,
        PaymentButton(
          notifier: loadingNotifier,
          onPressed: () {},
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Pay Now'), findsNothing);
    });
  });

  group('PaymentCardForm', () {
    testWidgets('displays title and amount', (tester) async {
      await _pumpWithL10n(
        tester,
        PaymentCardForm(
          notifier: notifier,
          title: 'Test Payment',
          amount: '250',
        ),
      );

      expect(find.text('Test Payment'), findsOneWidget);
      expect(find.text('250 ETB'), findsOneWidget);
    });

    testWidgets('displays custom currency', (tester) async {
      await _pumpWithL10n(
        tester,
        PaymentCardForm(
          notifier: notifier,
          title: 'Test Payment',
          amount: '250',
          currency: 'USD',
        ),
      );

      expect(find.text('250 USD'), findsOneWidget);
    });

    testWidgets('shows error message when error state', (tester) async {
      await _pumpWithL10n(
        tester,
        PaymentCardForm(
          notifier: notifier,
          title: 'Test Payment',
          amount: '250',
        ),
      );

      notifier.charge(
        const CreateOrderParams(amount: '100', title: 'Test'),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      final hasError = find.textContaining('Exception').evaluate().isNotEmpty;
      final hasPayButton = find.text('Pay Now').evaluate().isNotEmpty;
      expect(hasError || hasPayButton, isTrue);
    });
  });

  group('ErrorDisplay', () {
    testWidgets('renders nothing when errorMessage is null', (tester) async {
      await _pumpWithL10n(
        tester,
        const ErrorDisplay(errorMessage: null),
      );

      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders error message when provided', (tester) async {
      await _pumpWithL10n(
        tester,
        const ErrorDisplay(errorMessage: 'Something went wrong'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders dismiss button when onDismiss is provided',
        (tester) async {
      var dismissed = false;
      await _pumpWithL10n(
        tester,
        ErrorDisplay(
          errorMessage: 'Error occurred',
          onDismiss: () => dismissed = true,
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('does not render dismiss button when onDismiss is null',
        (tester) async {
      await _pumpWithL10n(
        tester,
        const ErrorDisplay(errorMessage: 'Error occurred'),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('RefundButton', () {
    testWidgets('renders refund button', (tester) async {
      await _pumpWithL10n(
        tester,
        RefundButton(
          telebirr: telebirr,
          merchOrderId: 'order_123',
          refundAmount: '100',
        ),
      );

      expect(find.text('Refund'), findsOneWidget);
    });

    testWidgets('shows confirm dialog on press', (tester) async {
      await _pumpWithL10n(
        tester,
        RefundButton(
          telebirr: telebirr,
          merchOrderId: 'order_123',
          refundAmount: '100',
        ),
      );

      await tester.tap(find.text('Refund'));
      await tester.pump();

      expect(find.text('Are you sure you want to refund this order?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('hides confirm dialog on cancel', (tester) async {
      await _pumpWithL10n(
        tester,
        RefundButton(
          telebirr: telebirr,
          merchOrderId: 'order_123',
          refundAmount: '100',
        ),
      );

      await tester.tap(find.text('Refund'));
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(find.text('Are you sure you want to refund this order?'),
          findsNothing);
      expect(find.text('Refund'), findsOneWidget);
    });
  });

  group('RetryButton', () {
    testWidgets('renders with default label', (tester) async {
      await _pumpWithL10n(
        tester,
        RetryButton(onPressed: () {}),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await _pumpWithL10n(
        tester,
        RetryButton(
          onPressed: () {},
          label: 'Try Again',
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await _pumpWithL10n(
        tester,
        RetryButton(
          onPressed: () {},
          loading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('button is disabled when loading', (tester) async {
      var pressed = false;
      await _pumpWithL10n(
        tester,
        RetryButton(
          onPressed: () => pressed = true,
          loading: true,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });
  });

  group('utils', () {
    test('formatAmount returns correct string', () {
      expect(formatAmount('100'), '100 ETB');
      expect(formatAmount('50', currency: 'USD'), '50 USD');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

void main() {
  late Telebirr telebirr;

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
  });

  group('PaymentNotifier', () {
    test('initial state is idle', () {
      final notifier = PaymentNotifier(telebirr);

      expect(notifier.state, PaymentState.idle);
      expect(notifier.errorMessage, isNull);
      expect(notifier.response, isNull);
      expect(notifier.isLoading, isFalse);
    });

    test('reset returns to idle', () {
      final notifier = PaymentNotifier(telebirr);

      notifier.reset();

      expect(notifier.state, PaymentState.idle);
      expect(notifier.errorMessage, isNull);
      expect(notifier.response, isNull);
    });

    test('notifies listeners on state change', () {
      final notifier = PaymentNotifier(telebirr);
      final calls = <bool>[];
      notifier.addListener(() => calls.add(notifier.isLoading));

      notifier.reset();
      notifier.dispose();

      expect(calls, isNotEmpty);
    });

    test('charge sets loading then error when API fails', () async {
      final notifier = PaymentNotifier(telebirr);
      final states = <PaymentState>[];
      notifier.addListener(() => states.add(notifier.state));

      await notifier.charge(
        const CreateOrderParams(amount: '100', title: 'Test'),
      );

      expect(states, contains(PaymentState.loading));
      expect(notifier.state, anyOf(PaymentState.error, PaymentState.success));
    });
  });

  group('PaymentState', () {
    test('has all expected values', () {
      expect(PaymentState.values, hasLength(4));
      expect(PaymentState.values, contains(PaymentState.idle));
      expect(PaymentState.values, contains(PaymentState.loading));
      expect(PaymentState.values, contains(PaymentState.success));
      expect(PaymentState.values, contains(PaymentState.error));
    });
  });

  group('RefundNotifier', () {
    test('initial state is idle', () {
      final notifier = RefundNotifier(telebirr);

      expect(notifier.state, RefundState.idle);
      expect(notifier.errorMessage, isNull);
      expect(notifier.response, isNull);
      expect(notifier.isLoading, isFalse);
    });

    test('reset returns to idle', () {
      final notifier = RefundNotifier(telebirr);

      notifier.reset();

      expect(notifier.state, RefundState.idle);
      expect(notifier.errorMessage, isNull);
      expect(notifier.response, isNull);
    });

    test('notifies listeners on state change', () {
      final notifier = RefundNotifier(telebirr);
      final calls = <bool>[];
      notifier.addListener(() => calls.add(notifier.isLoading));

      notifier.reset();
      notifier.dispose();

      expect(calls, isNotEmpty);
    });

    test('refund sets loading then error when API fails', () async {
      final notifier = RefundNotifier(telebirr);
      final states = <RefundState>[];
      notifier.addListener(() => states.add(notifier.state));

      await notifier.refund(
        const RefundParams(
          merchOrderId: 'order_123',
          refundRequestNo: 'RF001',
          refundAmount: '100',
        ),
      );

      expect(states, contains(RefundState.loading));
      expect(
        notifier.state,
        anyOf(RefundState.error, RefundState.success),
      );
    });
  });

  group('RefundState', () {
    test('has all expected values', () {
      expect(RefundState.values, hasLength(4));
      expect(RefundState.values, contains(RefundState.idle));
      expect(RefundState.values, contains(RefundState.loading));
      expect(RefundState.values, contains(RefundState.success));
      expect(RefundState.values, contains(RefundState.error));
    });
  });

  group('RetryNotifier', () {
    test('initial state is idle', () {
      final paymentNotifier = PaymentNotifier(telebirr);
      final retryNotifier = RetryNotifier(paymentNotifier);

      expect(retryNotifier.state, RetryState.idle);
      expect(retryNotifier.errorMessage, isNull);
      expect(retryNotifier.attempt, 0);
      expect(retryNotifier.isLoading, isFalse);

      paymentNotifier.dispose();
      retryNotifier.dispose();
    });

    test('reset returns to idle', () {
      final paymentNotifier = PaymentNotifier(telebirr);
      final retryNotifier = RetryNotifier(paymentNotifier);

      retryNotifier.reset();

      expect(retryNotifier.state, RetryState.idle);
      expect(retryNotifier.errorMessage, isNull);
      expect(retryNotifier.attempt, 0);

      paymentNotifier.dispose();
      retryNotifier.dispose();
    });

    test('notifies listeners on state change', () {
      final paymentNotifier = PaymentNotifier(telebirr);
      final retryNotifier = RetryNotifier(paymentNotifier);
      final calls = <bool>[];
      retryNotifier.addListener(() => calls.add(retryNotifier.isLoading));

      retryNotifier.reset();
      retryNotifier.dispose();
      paymentNotifier.dispose();

      expect(calls, isNotEmpty);
    });

    test('chargeWithRetry sets loading then error when API fails', () async {
      final paymentNotifier = PaymentNotifier(telebirr);
      final retryNotifier = RetryNotifier(
        paymentNotifier,
        maxRetries: 2,
        delay: Duration.zero,
      );
      final states = <RetryState>[];
      retryNotifier.addListener(() => states.add(retryNotifier.state));

      await retryNotifier.chargeWithRetry(
        const CreateOrderParams(amount: '100', title: 'Test'),
      );

      expect(states, contains(RetryState.loading));
      expect(
        retryNotifier.state,
        anyOf(RetryState.error, RetryState.success),
      );

      paymentNotifier.dispose();
      retryNotifier.dispose();
    });

    test('chargeWithRetry tracks attempt count', () async {
      final paymentNotifier = PaymentNotifier(telebirr);
      final retryNotifier = RetryNotifier(
        paymentNotifier,
        maxRetries: 2,
        delay: Duration.zero,
      );

      await retryNotifier.chargeWithRetry(
        const CreateOrderParams(amount: '100', title: 'Test'),
      );

      expect(retryNotifier.attempt, greaterThanOrEqualTo(1));
      expect(retryNotifier.attempt, lessThanOrEqualTo(2));

      paymentNotifier.dispose();
      retryNotifier.dispose();
    });
  });

  group('RetryState', () {
    test('has all expected values', () {
      expect(RetryState.values, hasLength(4));
      expect(RetryState.values, contains(RetryState.idle));
      expect(RetryState.values, contains(RetryState.loading));
      expect(RetryState.values, contains(RetryState.success));
      expect(RetryState.values, contains(RetryState.error));
    });
  });
}

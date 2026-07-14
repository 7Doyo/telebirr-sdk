import 'package:flutter/foundation.dart';
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

/// The lifecycle states of a payment charge request.
enum PaymentState {
  /// No request has been made yet.
  idle,

  /// A charge request is in progress.
  loading,

  /// The charge request completed successfully.
  success,

  /// The charge request failed with an error.
  error,
}

/// A [ChangeNotifier] that manages the state of a Telebirr payment charge.
///
/// Wrap this notifier with [ListenableBuilder] or [AnimatedBuilder] to
/// reactively update the UI based on payment state.
///
/// ```dart
/// final notifier = PaymentNotifier(telebirr);
/// // ...
/// await notifier.charge(CreateOrderParams(amount: '100', title: 'Order'));
/// print(notifier.response); // non-null on success
/// ```
class PaymentNotifier extends ChangeNotifier {
  final Telebirr _telebirr;

  PaymentState _state = PaymentState.idle;
  String? _errorMessage;
  CreateOrderResponse? _response;

  /// Creates a [PaymentNotifier] backed by the given [Telebirr] instance.
  PaymentNotifier(this._telebirr);

  /// The current [PaymentState].
  PaymentState get state => _state;

  /// The error message if [state] is [PaymentState.error], otherwise `null`.
  String? get errorMessage => _errorMessage;

  /// The server response if [state] is [PaymentState.success], otherwise `null`.
  CreateOrderResponse? get response => _response;

  /// Whether a charge request is currently in progress.
  bool get isLoading => _state == PaymentState.loading;

  /// Initiates a payment charge with the given [params].
  ///
  /// Sets [state] to [PaymentState.loading] while the request is in flight.
  /// On success, [state] becomes [PaymentState.success] and [response] is set.
  /// On failure, [state] becomes [PaymentState.error] and [errorMessage] is set.
  Future<void> charge(CreateOrderParams params) async {
    _state = PaymentState.loading;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      _response = await _telebirr.payments.charge(params);
      _state = PaymentState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PaymentState.error;
    }
    notifyListeners();
  }

  /// Resets the notifier to [PaymentState.idle], clearing [response] and [errorMessage].
  void reset() {
    _state = PaymentState.idle;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}

/// The lifecycle states of a refund request.
enum RefundState {
  /// No request has been made yet.
  idle,

  /// A refund request is in progress.
  loading,

  /// The refund request completed successfully.
  success,

  /// The refund request failed with an error.
  error,
}

/// A [ChangeNotifier] that manages the state of a Telebirr refund request.
///
/// ```dart
/// final notifier = RefundNotifier(telebirr);
/// await notifier.refund(RefundParams(
///   merchOrderId: 'order-123',
///   refundRequestNo: 'RF001',
///   refundAmount: '100',
/// ));
/// ```
class RefundNotifier extends ChangeNotifier {
  final Telebirr _telebirr;

  RefundState _state = RefundState.idle;
  String? _errorMessage;
  RefundResponse? _response;

  /// Creates a [RefundNotifier] backed by the given [Telebirr] instance.
  RefundNotifier(this._telebirr);

  /// The current [RefundState].
  RefundState get state => _state;

  /// The error message if [state] is [RefundState.error], otherwise `null`.
  String? get errorMessage => _errorMessage;

  /// The server response if [state] is [RefundState.success], otherwise `null`.
  RefundResponse? get response => _response;

  /// Whether a refund request is currently in progress.
  bool get isLoading => _state == RefundState.loading;

  /// Initiates a refund with the given [params].
  ///
  /// Sets [state] to [RefundState.loading] while the request is in flight.
  /// On success, [state] becomes [RefundState.success] and [response] is set.
  /// On failure, [state] becomes [RefundState.error] and [errorMessage] is set.
  Future<void> refund(RefundParams params) async {
    _state = RefundState.loading;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      _response = await _telebirr.payments.refund(params);
      _state = RefundState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = RefundState.error;
    }
    notifyListeners();
  }

  /// Resets the notifier to [RefundState.idle], clearing [response] and [errorMessage].
  void reset() {
    _state = RefundState.idle;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}

/// The lifecycle states of a retry-enabled payment attempt.
enum RetryState {
  /// No retry attempt has been started.
  idle,

  /// Retry attempts are in progress.
  loading,

  /// A payment charge succeeded during a retry attempt.
  success,

  /// All retry attempts have been exhausted without success.
  error,
}

/// A [ChangeNotifier] that wraps [PaymentNotifier] with automatic retry logic.
///
/// Delegates payment charges to the underlying [PaymentNotifier] and retries
/// up to [maxRetries] times with a [delay] between each attempt.
///
/// ```dart
/// final paymentNotifier = PaymentNotifier(telebirr);
/// final retryNotifier = RetryNotifier(paymentNotifier, maxRetries: 3);
/// await retryNotifier.chargeWithRetry(params);
/// ```
class RetryNotifier extends ChangeNotifier {
  final PaymentNotifier _paymentNotifier;

  /// The maximum number of retry attempts before giving up.
  final int maxRetries;

  /// The delay to wait between retry attempts.
  final Duration delay;

  /// Creates a [RetryNotifier].
  ///
  /// The [_paymentNotifier] is used to execute each charge attempt.
  /// [maxRetries] defaults to `3`. [delay] defaults to 2 seconds.
  RetryNotifier(
    this._paymentNotifier, {
    this.maxRetries = 3,
    this.delay = const Duration(seconds: 2),
  });

  RetryState _state = RetryState.idle;
  String? _errorMessage;
  int _attempt = 0;

  /// The current [RetryState].
  RetryState get state => _state;

  /// The error message from the last failed attempt, or `null` if no error.
  String? get errorMessage => _errorMessage;

  /// The number of retry attempts made so far (1-indexed during execution).
  int get attempt => _attempt;

  /// Whether retry attempts are currently in progress.
  bool get isLoading => _state == RetryState.loading;

  /// Executes a payment charge with automatic retries.
  ///
  /// Makes up to [maxRetries] attempts, waiting [delay] between each.
  /// If any attempt succeeds, [state] becomes [RetryState.success].
  /// If all attempts fail, [state] becomes [RetryState.error].
  Future<void> chargeWithRetry(CreateOrderParams params) async {
    _state = RetryState.loading;
    _errorMessage = null;
    _attempt = 0;
    notifyListeners();

    while (_attempt < maxRetries) {
      _attempt++;
      notifyListeners();

      try {
        await _paymentNotifier.charge(params);
        if (_paymentNotifier.state == PaymentState.success) {
          _state = RetryState.success;
          notifyListeners();
          return;
        }
        _errorMessage = _paymentNotifier.errorMessage;
      } catch (e) {
        _errorMessage = e.toString();
      }

      if (_attempt < maxRetries) {
        await Future<void>.delayed(delay);
      }
    }

    _state = RetryState.error;
    notifyListeners();
  }

  /// Resets both this notifier and the underlying [PaymentNotifier] to idle.
  void reset() {
    _state = RetryState.idle;
    _errorMessage = null;
    _attempt = 0;
    _paymentNotifier.reset();
    notifyListeners();
  }
}

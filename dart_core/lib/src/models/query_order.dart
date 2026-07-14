/// The unified payment status returned by the SDK.
///
/// This enum normalizes the different status strings from Telebirr's
/// query-order and webhook APIs into a single set of values.
///
/// | Telebirr Query Status | Webhook Status | SDK Status       |
/// |-----------------------|----------------|------------------|
/// | `PAY_SUCCESS`         | `Completed`    | [success]        |
/// | `PAY_FAILED`          | `Failure`      | [fail]           |
/// | `ORDER_CLOSED`        | `Expired`      | [timeout]        |
/// | `WAIT_PAY`            | `Pending`      | [pending]        |
/// | `PAYING`              | `Paying`       | [pending]        |
/// | —                     | —              | [accepted]       |
/// | —                     | —              | [refunding]      |
/// | —                     | —              | [refundSuccess]  |
/// | —                     | —              | [refundFailed]   |
enum PaymentStatus {
  /// Payment completed successfully.
  success,

  /// Payment failed.
  fail,

  /// Order expired or was closed without payment.
  timeout,

  /// Payment is pending or in progress.
  pending,

  /// Order accepted by Telebirr, awaiting further processing.
  accepted,

  /// A refund is currently in progress.
  refunding,

  /// Refund completed successfully.
  refundSuccess,

  /// Refund failed.
  refundFailed,
}

/// Internal mapping from Telebirr's raw status strings to [PaymentStatus].
const _telebirrStatusMap = {
  'PAY_SUCCESS': PaymentStatus.success,
  'PAY_FAILED': PaymentStatus.fail,
  'ORDER_CLOSED': PaymentStatus.timeout,
  'WAIT_PAY': PaymentStatus.pending,
  'PAYING': PaymentStatus.pending,
  'ACCEPTED': PaymentStatus.accepted,
  'REFUNDING': PaymentStatus.refunding,
  'REFUND_SUCCESS': PaymentStatus.refundSuccess,
  'REFUND_FAILED': PaymentStatus.refundFailed,
};

/// Maps a raw Telebirr status string to a [PaymentStatus] enum value.
///
/// Unknown status strings default to [PaymentStatus.pending].
///
/// [rawStatus] is the `trade_status` value from the Telebirr API response
/// (typically in UPPER_CASE like `'PAY_SUCCESS'`).
///
/// Returns the corresponding [PaymentStatus] value.
///
/// Example:
/// ```dart
/// final status = mapTelebirrStatus('PAY_SUCCESS');
/// assert(status == PaymentStatus.success);
/// ```
PaymentStatus mapTelebirrStatus(String rawStatus) {
  return _telebirrStatusMap[rawStatus] ?? PaymentStatus.pending;
}

/// Parameters for querying an existing order's status.
///
/// Example:
/// ```dart
/// final params = QueryOrderParams(merchOrderId: 'ORDER_12345');
/// final response = await payments.query(params);
/// print('Status: ${response.status}');
/// ```
class QueryOrderParams {
  /// The merchant order ID to query.
  ///
  /// This is the same `merch_order_id` that was used when creating the order.
  final String merchOrderId;

  /// Creates a [QueryOrderParams] for the given [merchOrderId].
  const QueryOrderParams({required this.merchOrderId});
}

/// The response from a query-order API call.
///
/// Contains the mapped [status] and the full raw response for inspection.
///
/// Example:
/// ```dart
/// final response = await payments.query(QueryOrderParams(merchOrderId: '123'));
/// if (response.status == PaymentStatus.success) {
///   print('Payment completed!');
/// }
/// ```
class QueryOrderResponse {
  /// The Telebirr API response code.
  ///
  /// `'0'` indicates a successful query; other values may indicate errors.
  final String code;

  /// The mapped payment status.
  ///
  /// Transformed from the raw `trade_status` string using [mapTelebirrStatus].
  final PaymentStatus status;

  /// The full raw response map from the Telebirr API.
  ///
  /// Useful for accessing fields not explicitly modeled, such as `trade_status`
  /// in its original string form.
  final Map<String, dynamic> rawResponse;

  /// Creates a [QueryOrderResponse] with the query result.
  const QueryOrderResponse({
    required this.code,
    required this.status,
    required this.rawResponse,
  });
}

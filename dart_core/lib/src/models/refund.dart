/// Parameters for requesting a refund on a previously paid order.
///
/// All fields except [refundReason] are required. The [merchOrderId] identifies
/// the original order, and [refundRequestNo] must be unique per refund attempt.
///
/// Example:
/// ```dart
/// final params = RefundParams(
///   merchOrderId: 'ORDER_12345',
///   refundRequestNo: 'REFUND_001',
///   refundAmount: '100',
///   refundReason: 'Customer requested cancellation',
/// );
/// final response = await payments.refund(params);
/// ```
class RefundParams {
  /// The original merchant order ID to refund.
  ///
  /// Must match the `merch_order_id` used when the order was created.
  final String merchOrderId;

  /// A unique identifier for this refund request.
  ///
  /// Use a different value for each refund attempt on the same order
  /// to prevent duplicate refunds.
  final String refundRequestNo;

  /// The refund amount in ETB (Ethiopian Birr).
  ///
  /// Must be a positive numeric string, e.g., `'100'` or `'50.75'`.
  /// Cannot exceed the original order amount.
  final String refundAmount;

  /// An optional reason for the refund.
  ///
  /// Displayed in the Telebirr merchant dashboard and may be shown to the user.
  final String? refundReason;

  /// Creates a [RefundParams] with the refund details.
  const RefundParams({
    required this.merchOrderId,
    required this.refundRequestNo,
    required this.refundAmount,
    this.refundReason,
  });
}

/// The response from a refund API call.
///
/// Contains the refund status and order ID on success, plus the full
/// raw response for inspection.
///
/// Example:
/// ```dart
/// final response = await payments.refund(params);
/// if (response.refundStatus == 'SUCCESS') {
///   print('Refund order: ${response.refundOrderId}');
/// }
/// ```
class RefundResponse {
  /// The Telebirr API response code.
  ///
  /// `'0'` indicates the refund request was accepted; other values
  /// indicate an error.
  final String code;

  /// An optional human-readable message from the API.
  ///
  /// May contain error details when the refund fails.
  final String? message;

  /// The refund order ID assigned by Telebirr.
  ///
  /// Present on successful refund requests. Use this to track the
  /// refund in your system.
  final String? refundOrderId;

  /// The refund status string from Telebirr (e.g., `'SUCCESS'`).
  ///
  /// May be `null` if the API response did not include a status.
  final String? refundStatus;

  /// The full raw response map from the Telebirr API.
  ///
  /// Useful for accessing any fields not explicitly modeled in this class.
  final Map<String, dynamic> rawResponse;

  /// Creates a [RefundResponse] with the refund result.
  const RefundResponse({
    required this.code,
    this.message,
    this.refundOrderId,
    this.refundStatus,
    required this.rawResponse,
  });
}

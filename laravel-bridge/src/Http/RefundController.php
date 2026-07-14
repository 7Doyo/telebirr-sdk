<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Http;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Telebirr\Sdk\Core\Models\RefundParams;

/**
 * Provides an HTTP endpoint for issuing Telebirr payment refunds.
 *
 * Validates the incoming refund request, forwards it to the
 * Telebirr SDK, and returns the result as a JSON response.
 */
class RefundController extends Controller
{
    /**
     * Handle a refund request.
     *
     * Validates the incoming request body for the required fields,
     * constructs a {@see \Telebirr\Sdk\Core\Models\RefundParams} instance,
     * and submits the refund through the Telebirr SDK.
     *
     * @param \Illuminate\Http\Request $request The incoming HTTP request. Expected body:
     *     - merch_order_id (required|string): Original merchant order ID.
     *     - refund_request_no (required|string): Unique refund request identifier.
     *     - refund_amount (required|string): Amount to refund in ETB.
     *     - refund_reason (optional|string): Human-readable refund reason.
     *
     * @return \Illuminate\Http\JsonResponse A JSON response with one of:
     *     - 200: refund was successful.
     *     - 422: refund was submitted but Telebirr reported a failure.
     *     - 500: an exception occurred during the request.
     *
     * @throws \Illuminate\Validation\ValidationException When required fields are missing.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'merch_order_id' => 'required|string',
            'refund_request_no' => 'required|string',
            'refund_amount' => 'required|string',
            'refund_reason' => 'nullable|string',
        ]);

        $params = new RefundParams(
            merchOrderId: $validated['merch_order_id'],
            refundRequestNo: $validated['refund_request_no'],
            refundAmount: $validated['refund_amount'],
            refundReason: $validated['refund_reason'] ?? null,
        );

        try {
            $response = telebirr()->payments->refund($params);

            return response()->json([
                'status' => $response->isSuccessful() ? 'success' : 'failed',
                'code' => $response->code,
                'message' => $response->message,
                'refund_order_id' => $response->refundOrderId,
                'refund_status' => $response->refundStatus,
            ], $response->isSuccessful() ? 200 : 422);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}

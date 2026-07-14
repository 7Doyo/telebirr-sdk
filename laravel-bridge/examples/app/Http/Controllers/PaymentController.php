<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Telebirr\Sdk\Core\Models\CreateOrderParams;
use Telebirr\Sdk\Core\Models\QueryOrderParams;
use Telebirr\Sdk\Core\Models\RefundParams;
use Telebirr\Sdk\Core\Webhook;

class PaymentController extends Controller
{
    public function charge(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => 'required|numeric|min:1',
            'title' => 'required|string|max:255',
            'orderId' => 'nullable|string',
            'redirectUrl' => 'nullable|url',
        ]);

        try {
            $result = telebirr()->payments->charge(new CreateOrderParams(
                orderId: $validated['orderId'] ?? uniqid('tlb_', true),
                amount: (string) $validated['amount'],
                title: $validated['title'],
                redirectUrl: $validated['redirectUrl'] ?? null,
            ));

            return response()->json([
                'success' => true,
                'prepayId' => $result->prepayId,
                'receiveCode' => $result->receiveCode,
                'message' => $result->message,
            ]);
        } catch (\Throwable $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function query(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'orderId' => 'required|string',
        ]);

        try {
            $result = telebirr()->payments->query(new QueryOrderParams(
                merchOrderId: $validated['orderId'],
            ));

            return response()->json([
                'success' => true,
                'status' => $result->status->value,
                'isTerminal' => $result->status->isTerminal(),
            ]);
        } catch (\Throwable $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function refund(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'orderId' => 'required|string',
            'refundRequestNo' => 'required|string',
            'refundAmount' => 'required|numeric|min:1',
            'refundReason' => 'nullable|string',
        ]);

        try {
            $result = telebirr()->payments->refund(new RefundParams(
                merchOrderId: $validated['orderId'],
                refundRequestNo: $validated['refundRequestNo'],
                refundAmount: (string) $validated['refundAmount'],
                refundReason: $validated['refundReason'] ?? null,
            ));

            return response()->json([
                'success' => true,
                'refundOrderId' => $result->refundOrderId,
                'refundStatus' => $result->refundStatus,
                'message' => $result->message,
            ]);
        } catch (\Throwable $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function webhook(Request $request): JsonResponse
    {
        $payload = $request->all();
        $privateKey = config('telebirr.private_key', '');

        if ($privateKey === '') {
            return response()->json(['error' => 'Private key not configured'], 500);
        }

        $verified = Webhook::verify($payload, $privateKey);

        if (!$verified) {
            return response()->json(['error' => 'Invalid signature'], 401);
        }

        \Illuminate\Support\Facades\Log::info('Telebirr webhook received', [
            'order_id' => $payload['merch_order_id'] ?? null,
            'trade_status' => $payload['trade_status'] ?? null,
            'amount' => $payload['total_amount'] ?? null,
        ]);

        return response()->json(['status' => 'ok']);
    }

    public function receiveCode(string $prepayId): JsonResponse
    {
        $code = telebirr_receive_code('0', $prepayId);

        return response()->json(['receiveCode' => $code]);
    }
}

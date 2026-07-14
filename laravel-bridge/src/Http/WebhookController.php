<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Http;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Telebirr\Laravel\Events\WebhookReceived;
use Telebirr\Sdk\Core\Webhook;

/**
 * Handles incoming Telebirr webhook notifications.
 *
 * This controller is invokable — map it directly to a route. On every
 * request it verifies the cryptographic signature, dispatches a
 * {@see WebhookReceived} event, and returns an appropriate JSON response.
 */
class WebhookController extends Controller
{
    /**
     * Process a single Telebirr webhook notification.
     *
     * 1. Extracts the raw request payload.
     * 2. Verifies the payload signature against the configured private key.
     * 3. Dispatches a {@see WebhookReceived} event for downstream listeners.
     * 4. Returns a JSON acknowledgement.
     *
     * @param \Illuminate\Http\Request $request The incoming HTTP request containing the
     *                                         signed webhook payload.
     *
     * @return \Illuminate\Http\JsonResponse A JSON response with one of:
     *     - 200: webhook accepted and event dispatched.
     *     - 401: payload signature verification failed.
     *     - 500: private key is not configured.
     */
    public function __invoke(Request $request): JsonResponse
    {
        $payload = $request->all();
        $privateKey = config('telebirr.private_key', '');

        if ($privateKey === '') {
            return response()->json([
                'status' => 'error',
                'message' => 'Private key not configured',
            ], 500);
        }

        try {
            $verified = Webhook::verify($payload, $privateKey);
        } catch (\Throwable) {
            $verified = false;
        }

        if (! $verified) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid signature',
            ], 401);
        }

        event(new WebhookReceived($payload));

        return response()->json(['status' => 'ok'], 200);
    }
}

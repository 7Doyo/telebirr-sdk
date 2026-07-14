<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Routes;

use Illuminate\Support\Facades\Route;
use Telebirr\Laravel\Http\RefundController;
use Telebirr\Laravel\Http\WebhookController;

/**
 * Registers the HTTP routes used by the Telebirr webhook and refund endpoints.
 *
 * The webhook endpoint receives payment notifications from Telebirr
 * and the refund endpoint provides a simple API for issuing refunds
 * from within the host application.
 */
class WebhookRoutes
{
    /**
     * Register the Telebirr webhook and refund routes under the root URL prefix.
     *
     * Creates two POST routes:
     * - {@code POST /telebirr/webhook} — handled by {@see WebhookController}
     * - {@code POST /telebirr/refund}  — handled by {@see RefundController::store()}
     *
     * @return void
     */
    public static function register(): void
    {
        Route::post('/telebirr/webhook', WebhookController::class)
            ->name('telebirr.webhook');

        Route::post('/telebirr/refund', [RefundController::class, 'store'])
            ->name('telebirr.refund');
    }

    /**
     * Register the Telebirr webhook and refund routes under the {@code /api} prefix.
     *
     * Identical to {@see register()} but wraps both routes inside a
     * {@code /api} group prefix so they become:
     * - {@code POST /api/telebirr/webhook}
     * - {@code POST /api/telebirr/refund}
     *
     * @return void
     */
    public static function registerApi(): void
    {
        Route::prefix('api')->group(function (): void {
            Route::post('/telebirr/webhook', WebhookController::class)
                ->name('telebirr.webhook');

            Route::post('/telebirr/refund', [RefundController::class, 'store'])
                ->name('telebirr.refund');
        });
    }
}

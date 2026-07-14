<?php

declare(strict_types=1);

namespace Telebirr\Laravel;

use Illuminate\Support\Facades\Facade;
use Telebirr\Sdk\Core\Telebirr;

/**
 * Facade for the Telebirr payment gateway SDK.
 *
 * Provides static access to the underlying {@see Telebirr} service
 * container binding, allowing convenient calls such as
 * {@code Telebirr::payments()->charge($params)}.
 *
 * @method static \Telebirr\Sdk\Core\Payments payments()
 *     Access the Payments service to charge, refund, or query orders.
 * @see \Telebirr\Sdk\Core\Telebirr
 */
class TelebirrFacade extends Facade
{
    /**
     * Resolve the facade accessor from the service container.
     *
     * Returns the fully-qualified class name of the Telebirr core
     * service, which must be registered as a singleton by
     * {@see TelebirrServiceProvider}.
     *
     * @return class-string<\Telebirr\Sdk\Core\Telebirr>
     */
    protected static function getFacadeAccessor(): string
    {
        return Telebirr::class;
    }
}

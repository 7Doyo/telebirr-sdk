<?php

declare(strict_types=1);

namespace Telebirr\Laravel;

use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;
use Telebirr\Laravel\Events\PaymentFailed;
use Telebirr\Laravel\Events\PaymentSucceeded;
use Telebirr\Laravel\Routes\WebhookRoutes;
use Telebirr\Sdk\Core\Telebirr;
use Telebirr\Sdk\Core\Models\Config;

/**
 * Laravel service provider for the Telebirr payment gateway bridge.
 *
 * Registers the Telebirr SDK singleton in the service container,
 * publishes configuration and translation files, loads webhook
 * and refund routes, and wires up any user-defined event listeners.
 */
class TelebirrServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * Publishes the {@code telebirr.php} config and language files so
     * they can be customised by the host application, merges the
     * package defaults, and registers the HTTP routes that Telebirr
     * will call for webhooks and refunds.
     *
     * @return void
     */
    public function boot(): void
    {
        $this->publishes([
            __DIR__ . '/../config/telebirr.php' => config_path('telebirr.php'),
        ], 'telebirr-config');

        $this->mergeConfigFrom(
            __DIR__ . '/../config/telebirr.php', 'telebirr'
        );

        $this->loadTranslationsFrom(__DIR__ . '/../lang', 'telebirr');

        $this->publishes([
            __DIR__ . '/../lang' => $this->app->langPath('vendor/telebirr'),
        ], 'telebirr-lang');

        if ($this->app->runningInConsole()) {
            WebhookRoutes::register();
        }

        $this->registerEventListeners();
    }

    /**
     * Register the Telebirr SDK singleton in the application container.
     *
     * Reads every configuration key from {@code config('telebirr')} and
     * passes it into a new {@see Config} model, which is then used to
     * construct the {@see Telebirr} instance.
     *
     * @return void
     */
    public function register(): void
    {
        $this->app->singleton(Telebirr::class, function () {
            $config = config('telebirr');

            return new Telebirr(new Config(
                environment: $config['environment'],
                fabricAppId: $config['fabric_app_id'],
                merchantAppId: $config['merchant_app_id'],
                merchantCode: $config['merchant_code'],
                apiKey: $config['api_key'],
                privateKeyPem: $config['private_key'],
                shortCode: $config['short_code'],
                timeout: $config['timeout'],
                notifyUrl: $config['notify_url'],
                baseUrl: $config['base_url'],
            ));
        });
    }

    /**
     * Get the services provided by the package.
     *
     * Declares that this provider supplies the {@see Telebirr} class,
     * enabling deferred loading when the SDK is resolved from the
     * container.
     *
     * @return array{0: class-string<\Telebirr\Sdk\Core\Telebirr>}
     */
    public function provides(): array
    {
        return [Telebirr::class];
    }

    /**
     * Register all event listeners defined in the {@code telebirr.listeners} config.
     *
     * Each entry is an event class name mapped to its listener class.
     * Listeners are only wired when the package is running inside a
     * full Laravel application (i.e. the {@see Event} facade exists).
     *
     * @return void
     */
    private function registerEventListeners(): void
    {
        if (! class_exists(Event::class)) {
            return;
        }

        $listeners = config('telebirr.listeners', []);

        foreach ($listeners as $event => $listener) {
            Event::listen($event, $listener);
        }
    }
}

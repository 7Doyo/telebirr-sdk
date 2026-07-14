<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Tests\Unit;

use Telebirr\Laravel\Tests\TestCase;
use Telebirr\Sdk\Core\Telebirr;

class ServiceProviderTest extends TestCase
{
    public function test_telebirr_is_registered_in_container(): void
    {
        $this->assertTrue($this->app->bound(Telebirr::class));
    }

    public function test_config_is_merged(): void
    {
        $this->assertEquals('SANDBOX', config('telebirr.environment'));
    }

    public function test_config_can_be_published(): void
    {
        $this->artisan('vendor:publish', ['--tag' => 'telebirr-config']);
        $this->assertFileExists(config_path('telebirr.php'));
    }

    public function test_translations_are_loaded(): void
    {
        $this->assertEquals('Pay Now', trans('telebirr::messages.pay_now'));
    }

    public function test_translations_localization_works(): void
    {
        app()->setLocale('am');
        $this->assertEquals('አሁን ይክፈሉ', trans('telebirr::messages.pay_now'));

        app()->setLocale('en');
        $this->assertEquals('Pay Now', trans('telebirr::messages.pay_now'));
    }

    public function test_translations_can_be_published(): void
    {
        $this->artisan('vendor:publish', ['--tag' => 'telebirr-lang']);
        $this->assertFileExists(lang_path('vendor/telebirr/en/messages.php'));
        $this->assertFileExists(lang_path('vendor/telebirr/am/messages.php'));
    }

    public function test_locale_config_defaults_to_app_locale(): void
    {
        $this->assertEquals(config('app.locale', 'en'), config('telebirr.locale'));
    }

    public function test_new_translation_keys_exist_in_all_locales(): void
    {
        $keys = [
            'refund', 'refund_confirm', 'refund_processing', 'refund_success', 'refund_failed',
            'retry', 'retry_countdown', 'retry_failed',
            'error_generic', 'error_network', 'error_timeout', 'error_auth', 'error_validation', 'error_dismiss',
            'webhook_verification_failed',
            'status_accepted', 'status_refunding', 'status_refund_success', 'status_refund_failed',
        ];

        $locales = ['en', 'am', 'ar', 'om', 'ti'];

        foreach ($locales as $locale) {
            app()->setLocale($locale);
            foreach ($keys as $key) {
                $translated = trans("telebirr::messages.{$key}");
                $this->assertNotEquals(
                    "telebirr::messages.{$key}",
                    $translated,
                    "Translation key '{$key}' is missing in locale '{$locale}'"
                );
            }
        }

        app()->setLocale('en');
    }

    public function test_refund_translation_key_exists(): void
    {
        $this->assertNotEquals(
            'telebirr::messages.refund',
            trans('telebirr::messages.refund')
        );
    }

    public function test_webhook_verification_failed_translation_key_exists(): void
    {
        $this->assertNotEquals(
            'telebirr::messages.webhook_verification_failed',
            trans('telebirr::messages.webhook_verification_failed')
        );
    }

    public function test_status_accepted_translation_key_exists(): void
    {
        $this->assertNotEquals(
            'telebirr::messages.status_accepted',
            trans('telebirr::messages.status_accepted')
        );
    }

    public function test_listeners_config_defaults_to_empty_array(): void
    {
        $this->assertIsArray(config('telebirr.listeners'));
        $this->assertEmpty(config('telebirr.listeners'));
    }
}

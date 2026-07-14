<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Tests\Unit;

use Illuminate\Support\Facades\Event;
use Telebirr\Laravel\Events\WebhookReceived;
use Telebirr\Laravel\Tests\TestCase;

class WebhookControllerTest extends TestCase
{
    private string $privateKeyPem = '';
    private string $publicKeyPem = '';
    private string $tempConfig = '';

    protected function setUp(): void
    {
        parent::setUp();

        $this->tempConfig = tempnam(sys_get_temp_dir(), 'ssl');
        file_put_contents($this->tempConfig, 'HOME = .
RANDFILE = $ENV::HOME/.rnd
[req]
default_bits = 2048
distinguished_name = req_dn
prompt = no
[req_dn]
CN = Test
');

        $resource = openssl_pkey_new([
            'config' => $this->tempConfig,
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ]);

        if ($resource === false) {
            $this->markTestSkipped('Unable to generate RSA key pair: ' . openssl_error_string());
        }

        openssl_pkey_export($resource, $this->privateKeyPem, '', ['config' => $this->tempConfig]);
        $details = openssl_pkey_get_details($resource);
        $this->publicKeyPem = $details['key'];
        openssl_pkey_free($resource);

        config()->set('telebirr.private_key', $this->publicKeyPem);
    }

    protected function tearDown(): void
    {
        if (file_exists($this->tempConfig)) {
            unlink($this->tempConfig);
        }

        parent::tearDown();
    }

    private function signPayload(array $payload): string
    {
        $fields = [];
        $fieldMap = [];

        foreach ($payload as $key => $value) {
            if (in_array($key, ['sign', 'sign_type'], true)) {
                continue;
            }
            if ($value === null) {
                continue;
            }
            $fields[] = $key;
            $fieldMap[$key] = (string) $value;
        }

        sort($fields, SORT_STRING);

        $parts = [];
        foreach ($fields as $field) {
            $parts[] = $field . '=' . $fieldMap[$field];
        }

        $signString = implode('&', $parts);

        openssl_sign($signString, $signature, $this->privateKeyPem, OPENSSL_ALGO_SHA256);

        return base64_encode($signature);
    }

    public function test_webhook_returns_ok_for_valid_signature(): void
    {
        $payload = [
            'appid' => '12345',
            'merch_code' => 'TEST_MERCHANT',
            'merch_order_id' => 'ORDER_001',
            'total_amount' => '100',
            'trade_status' => 'Completed',
            'sign_type' => 'SHA256WithRSA',
        ];
        $payload['sign'] = $this->signPayload($payload);

        Event::fake();

        $response = $this->postJson('/telebirr/webhook', $payload);

        Event::assertDispatched(WebhookReceived::class);

        $response->assertOk();
        $response->assertJson(['status' => 'ok']);
    }

    public function test_webhook_returns_401_for_invalid_signature(): void
    {
        $payload = [
            'appid' => '12345',
            'merch_order_id' => 'ORDER_002',
            'total_amount' => '100',
            'sign' => 'invalid-signature',
            'sign_type' => 'SHA256WithRSA',
        ];

        Event::fake();

        $response = $this->postJson('/telebirr/webhook', $payload);

        Event::assertNotDispatched(WebhookReceived::class);

        $response->assertUnauthorized();
        $response->assertJson([
            'status' => 'error',
            'message' => 'Invalid signature',
        ]);
    }

    public function test_webhook_returns_500_when_private_key_not_configured(): void
    {
        config()->set('telebirr.private_key', '');

        $payload = [
            'appid' => '12345',
            'sign' => 'some-sign',
        ];

        Event::fake();

        $response = $this->postJson('/telebirr/webhook', $payload);

        Event::assertNotDispatched(WebhookReceived::class);

        $response->assertStatus(500);
        $response->assertJson([
            'status' => 'error',
            'message' => 'Private key not configured',
        ]);
    }

    public function test_webhook_dispatches_event_with_payload(): void
    {
        $payload = [
            'appid' => '12345',
            'merch_order_id' => 'ORDER_003',
            'total_amount' => '200',
            'trade_status' => 'Completed',
            'sign_type' => 'SHA256WithRSA',
        ];
        $payload['sign'] = $this->signPayload($payload);

        Event::fake();

        $this->postJson('/telebirr/webhook', $payload);

        Event::assertDispatched(WebhookReceived::class, function (WebhookReceived $event) use ($payload): bool {
            return $event->payload === $payload;
        });
    }

    public function test_webhook_rejects_tampered_payload(): void
    {
        $payload = [
            'appid' => '12345',
            'merch_order_id' => 'ORDER_004',
            'total_amount' => '100',
            'trade_status' => 'Completed',
            'sign_type' => 'SHA256WithRSA',
        ];
        $payload['sign'] = $this->signPayload($payload);

        $payload['total_amount'] = '99999';

        Event::fake();

        $response = $this->postJson('/telebirr/webhook', $payload);

        Event::assertNotDispatched(WebhookReceived::class);

        $response->assertUnauthorized();
    }
}

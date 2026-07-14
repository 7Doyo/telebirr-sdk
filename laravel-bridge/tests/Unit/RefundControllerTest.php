<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Tests\Unit;

use Telebirr\Laravel\Tests\TestCase;

class RefundControllerTest extends TestCase
{
    public function test_refund_store_validates_required_fields(): void
    {
        $response = $this->postJson('/telebirr/refund', []);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors([
            'merch_order_id',
            'refund_request_no',
            'refund_amount',
        ]);
    }

    public function test_refund_store_validates_merch_order_id_required(): void
    {
        $response = $this->postJson('/telebirr/refund', [
            'refund_request_no' => 'REF_001',
            'refund_amount' => '50',
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['merch_order_id']);
    }

    public function test_refund_store_validates_refund_request_no_required(): void
    {
        $response = $this->postJson('/telebirr/refund', [
            'merch_order_id' => 'ORDER_001',
            'refund_amount' => '50',
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['refund_request_no']);
    }

    public function test_refund_store_validates_refund_amount_required(): void
    {
        $response = $this->postJson('/telebirr/refund', [
            'merch_order_id' => 'ORDER_001',
            'refund_request_no' => 'REF_001',
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['refund_amount']);
    }

    public function test_refund_store_allows_nullable_refund_reason(): void
    {
        $response = $this->postJson('/telebirr/refund', [
            'merch_order_id' => 'ORDER_001',
            'refund_request_no' => 'REF_001',
            'refund_amount' => '50',
        ]);

        $response->assertJsonMissingValidationErrors(['refund_reason']);
    }

    public function test_refund_store_returns_error_on_sdk_failure(): void
    {
        config()->set('telebirr.base_url', 'https://nonexistent.invalid');

        $response = $this->postJson('/telebirr/refund', [
            'merch_order_id' => 'ORDER_001',
            'refund_request_no' => 'REF_001',
            'refund_amount' => '50',
            'refund_reason' => 'Customer request',
        ]);

        $response->assertStatus(500);
        $response->assertJson([
            'status' => 'error',
        ]);
    }
}

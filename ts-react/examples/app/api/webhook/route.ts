import { NextResponse } from 'next/server';
import { verifyNotification } from '@telebirr/sdk-core';
import type { NotificationPayload } from '@telebirr/sdk-core';

export async function POST(request: Request) {
  try {
    const payload: NotificationPayload = await request.json();
    const publicKey = process.env.TELEBIRR_PUBLIC_KEY?.replace(/\\n/g, '\n') ?? '';

    const isValid = verifyNotification(payload, publicKey);
    if (!isValid) {
      console.warn('Invalid webhook signature');
      return NextResponse.json(
        { error: 'Invalid signature' },
        { status: 401 },
      );
    }

    console.log('Webhook received:', {
      orderId: payload.merch_order_id,
      tradeStatus: payload.trade_status,
      amount: payload.total_amount,
    });

    return NextResponse.json({ status: 'ok' });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('Webhook error:', message);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

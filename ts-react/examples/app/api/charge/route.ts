import { NextResponse } from 'next/server';
import { Telebirr } from '@telebirr-sdk/sdk-core';
import type { TelebirrConfig } from '@telebirr-sdk/sdk-core';

function getConfig(): TelebirrConfig {
  return {
    environment: (process.env.TELEBIRR_ENVIRONMENT as 'SANDBOX' | 'PRODUCTION') ?? 'SANDBOX',
    fabricAppId: process.env.TELEBIRR_FABRIC_APP_ID!,
    merchantAppId: process.env.TELEBIRR_MERCHANT_APP_ID!,
    merchantCode: process.env.TELEBIRR_MERCHANT_CODE!,
    appSecret: process.env.TELEBIRR_API_KEY!,
    privateKeyPem: process.env.TELEBIRR_PRIVATE_KEY!.replace(/\\n/g, '\n'),
    shortCode: process.env.TELEBIRR_SHORT_CODE ?? '220311',
    timeout: process.env.TELEBIRR_TIMEOUT ?? '120m',
    notifyUrl: process.env.TELEBIRR_NOTIFY_URL!,
  };
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { amount, title, orderId, redirectUrl } = body;

    if (!amount || !title) {
      return NextResponse.json(
        { error: 'amount and title are required' },
        { status: 400 },
      );
    }

    const telebirr = new Telebirr(getConfig());
    const result = await telebirr.payments.charge({
      amount: String(amount),
      title,
      orderId,
      redirectUrl,
    });

    return NextResponse.json({
      success: true,
      prepayId: result.prepayId,
      receiveCode: result.receiveCode,
      message: result.message,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('Charge API error:', message);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

'use client';

import { useState } from 'react';
import { TelebirrProvider, PaymentButton, TestModeBadge } from '@telebirr/react-elements';
import type { TelebirrConfig } from '@telebirr/sdk-core';

const config: TelebirrConfig = {
  environment: (process.env.NEXT_PUBLIC_TELEBIRR_ENVIRONMENT as 'SANDBOX' | 'PRODUCTION') ?? 'SANDBOX',
  fabricAppId: process.env.NEXT_PUBLIC_TELEBIRR_FABRIC_APP_ID ?? '',
  merchantAppId: process.env.NEXT_PUBLIC_TELEBIRR_MERCHANT_APP_ID ?? '',
  merchantCode: process.env.NEXT_PUBLIC_TELEBIRR_MERCHANT_CODE ?? '',
  appSecret: process.env.NEXT_PUBLIC_TELEBIRR_API_KEY ?? '',
  privateKeyPem: '',
  shortCode: process.env.NEXT_PUBLIC_TELEBIRR_SHORT_CODE ?? '220311',
  timeout: '120m',
  notifyUrl: '',
};

export default function HomePage() {
  const [amount, setAmount] = useState('100');
  const [title, setTitle] = useState('Test Payment');
  const [result, setResult] = useState<string | null>(null);

  return (
    <TelebirrProvider config={config}>
      <main>
        <h1>Telebirr Payment</h1>
        <TestModeBadge />

        <div style={{ marginTop: 16 }}>
          <label style={{ display: 'block', marginBottom: 8 }}>
            Amount (ETB)
            <input
              type="number"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              style={{ display: 'block', width: '100%', padding: 8, marginTop: 4 }}
            />
          </label>

          <label style={{ display: 'block', marginBottom: 8 }}>
            Title
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              style={{ display: 'block', width: '100%', padding: 8, marginTop: 4 }}
            />
          </label>
        </div>

        <PaymentButton
          params={{ amount, title }}
          onSuccess={(response) => {
            setResult(`Payment created! Prepay ID: ${response.prepayId}`);
          }}
          onError={(error) => {
            setResult(`Error: ${error.message}`);
          }}
          className="pay-button"
        />

        {result && (
          <div style={{ marginTop: 16, padding: 12, background: '#f0f0f0', borderRadius: 6 }}>
            {result}
          </div>
        )}
      </main>
    </TelebirrProvider>
  );
}

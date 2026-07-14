import 'dotenv/config';
import express from 'express';
import { Telebirr, PaymentStatus, verifyNotification } from '@telebirr-sdk/sdk-core';
import type {
  TelebirrConfig,
  NotificationPayload,
} from '@telebirr-sdk/sdk-core';

const app = express();
app.use(express.json());

const config: TelebirrConfig = {
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

const telebirr = new Telebirr(config);

app.post('/charge', async (req, res) => {
  try {
    const { amount, title, orderId, redirectUrl } = req.body;

    if (!amount || !title) {
      res.status(400).json({ error: 'amount and title are required' });
      return;
    }

    const result = await telebirr.payments.charge({
      amount: String(amount),
      title,
      orderId,
      redirectUrl,
    });

    res.json({
      success: true,
      prepayId: result.prepayId,
      receiveCode: result.receiveCode,
      message: result.message,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('Charge failed:', message);
    res.status(500).json({ error: message });
  }
});

app.post('/query', async (req, res) => {
  try {
    const { orderId } = req.body;

    if (!orderId) {
      res.status(400).json({ error: 'orderId is required' });
      return;
    }

    const result = await telebirr.payments.query({ merchOrderId: orderId });

    res.json({
      success: true,
      status: result.status,
      isTerminal: result.status !== PaymentStatus.PENDING && result.status !== PaymentStatus.ACCEPTED,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('Query failed:', message);
    res.status(500).json({ error: message });
  }
});

app.post('/refund', async (req, res) => {
  try {
    const { orderId, refundRequestNo, refundAmount, refundReason } = req.body;

    if (!orderId || !refundRequestNo || !refundAmount) {
      res.status(400).json({ error: 'orderId, refundRequestNo, and refundAmount are required' });
      return;
    }

    const result = await telebirr.payments.refund({
      merchOrderId: orderId,
      refundRequestNo,
      refundAmount: String(refundAmount),
      refundReason,
    });

    res.json({
      success: true,
      refundOrderId: result.refundOrderId,
      refundStatus: result.refundStatus,
      message: result.message,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('Refund failed:', message);
    res.status(500).json({ error: message });
  }
});

app.post('/webhook', (req, res) => {
  try {
    const payload = req.body as NotificationPayload;
    const publicKey = process.env.TELEBIRR_PUBLIC_KEY?.replace(/\\n/g, '\n') ?? '';

    const isValid = verifyNotification(payload, publicKey);
    if (!isValid) {
      console.warn('Invalid webhook signature');
      res.status(401).json({ error: 'Invalid signature' });
      return;
    }

    console.log('Webhook received:', {
      orderId: payload.merch_order_id,
      tradeStatus: payload.trade_status,
      amount: payload.total_amount,
    });

    res.json({ status: 'ok' });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('Webhook processing failed:', message);
    res.status(500).json({ error: message });
  }
});

app.get('/receive-code/:prepayId', (req, res) => {
  const { prepayId } = req.params;

  if (!prepayId) {
    res.status(400).json({ error: 'prepayId is required' });
    return;
  }

  const receiveCode = telebirr.payments.buildReceiveCode(prepayId);

  res.json({ receiveCode });
});

const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, () => {
  console.log(`Telebirr Express example running on http://localhost:${PORT}`);
  console.log(`Environment: ${config.environment}`);
});

# Telebirr Next.js Example

A Next.js app demonstrating `@telebirr/sdk-core` (API routes) and `@telebirr/react-elements` (UI components).

## Setup

```bash
cp .env.example .env.local
# Edit .env.local with your Telebirr developer credentials

npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see the payment form.

## Structure

- `app/page.tsx` — Client-side payment form using `TelebirrProvider`, `PaymentButton`, and `TestModeBadge`
- `app/api/charge/route.ts` — Server-side API route that creates a payment order
- `app/api/webhook/route.ts` — Server-side webhook handler that verifies notification signatures

## Environment Variables

Public variables (prefixed `NEXT_PUBLIC_`) are used client-side for the provider. Private variables are used server-side for signing.

## Notes

- The `privateKeyPem` should only be used server-side (in API routes), never exposed to the browser.
- In production, store the private key in an environment variable or secret manager.

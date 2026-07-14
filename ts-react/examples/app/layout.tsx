// import type { Metadata } from 'react';
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Telebirr Next.js Example',
  description: 'Payment integration with @telebirr-sdk/sdk-core and @telebirr-sdk/react-elements',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, sans-serif', maxWidth: 640, margin: '0 auto', padding: 24 }}>
        {children}
      </body>
    </html>
  );
}

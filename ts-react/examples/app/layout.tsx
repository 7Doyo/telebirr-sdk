import type { Metadata } from 'react';
import './globals.css';

export const metadata: Metadata = {
  title: 'Telebirr Next.js Example',
  description: 'Payment integration with @telebirr/sdk-core and @telebirr/react-elements',
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

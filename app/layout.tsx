import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Rabbit Forms - Complete Form Builder SaaS',
  description: 'Build, manage, and analyze forms with ease. Open-source form builder with conditional logic, analytics, and more.',
  keywords: ['form builder', 'saas', 'forms', 'surveys', 'conditional logic'],
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="font-sans antialiased">{children}</body>
    </html>
  )
}

# 🐰 Rabbit Forms

**A complete open-source Form Builder SaaS solution** - Build, manage, and analyze forms with ease.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green)](https://supabase.com/)

## Overview

Rabbit Forms is a multi-tenant form builder SaaS targeting deployment on Vercel with Supabase as the backend platform. It provides enterprise-grade form building capabilities with an intuitive drag-and-drop interface, conditional logic, analytics, and much more.

## Key Features

- **Multi-Tenancy**: Super Admin manages multiple businesses, each with their own admins
- **Drag-and-Drop Form Builder**: Visual form creation with 10+ field types
- **Conditional Logic**: No-code IF-THEN rules with database lookups
- **Smart Duplicate Detection**: Prevent duplicate submissions based on time windows
- **Digital Signatures**: Built-in signature capture and storage
- **Multi-Step Forms**: Create single-page or multi-step form experiences
- **Advanced Analytics**: Submission tracking, completion rates, and exports (CSV/JSON)
- **Email Notifications**: Fully configurable notification system
- **Custom Branding**: Per-business themes, logos, and colors
- **REST API**: Programmatic access with API key authentication
- **CAPTCHA Protection**: Optional spam prevention (Cloudflare Turnstile, reCAPTCHA)
- **Data Retention**: Automated cleanup policies for compliance
- **Mobile Responsive**: Works seamlessly on all devices

## Tech Stack

- **Framework**: [Next.js 14+](https://nextjs.org/) (App Router)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **Database**: [Supabase](https://supabase.com/) (PostgreSQL + Auth + Storage)
- **UI Components**: [shadcn/ui](https://ui.shadcn.com/) + [Radix UI](https://www.radix-ui.com/)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Drag & Drop**: [@dnd-kit](https://dndkit.com/)
- **Forms**: [React Hook Form](https://react-hook-form.com/)
- **Deployment**: [Vercel](https://vercel.com/)

## Documentation

- **[Implementation Plan](./RABBIT_FORMS_IMPLEMENTATION_PLAN.md)** - Complete technical specification, database schema, and development roadmap
- **[Original Plan](./PLAN.md)** - Initial planning artifacts and task stubs

## Quick Start

### Prerequisites

- Node.js 18+ and npm/pnpm/yarn
- Supabase account (free tier works)
- Vercel account (optional, for deployment)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/rabbit-forms.git
cd rabbit-forms

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Set up your Supabase credentials in .env.local
# Then run the development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Project Status

This project is currently in the planning and initial development phase. See the [Implementation Plan](./RABBIT_FORMS_IMPLEMENTATION_PLAN.md) for the complete 13-week development roadmap.

### Development Phases

1. **Phase 1**: Foundation (Weeks 1-2) - Setup, auth, super admin dashboard
2. **Phase 2**: Form Builder Core (Weeks 3-4) - Drag-and-drop builder
3. **Phase 3**: Form Rendering (Week 5) - Public forms, signatures
4. **Phase 4**: Conditional Logic (Week 6) - Visual logic builder, duplicate checks
5. **Phase 5**: Analytics (Week 7) - Dashboard, exports
6. **Phase 6**: Email Notifications (Week 8)
7. **Phase 7**: Customization (Week 9) - Branding, themes
8. **Phase 8**: API (Week 10) - REST API, authentication
9. **Phase 9**: Security (Week 11) - CAPTCHA, retention policies
10. **Phase 10**: Testing (Week 12) - Unit, integration, E2E tests
11. **Phase 11**: Launch (Week 13) - Polish, deploy, open-source release

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/rabbit-forms/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/rabbit-forms/discussions)

---

**Built with ❤️ by the open-source community**

Star ⭐ this repo if you find it useful!

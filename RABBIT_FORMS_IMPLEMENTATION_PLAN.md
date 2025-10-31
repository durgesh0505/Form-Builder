# Rabbit Forms - Complete Implementation Plan

## Project Overview
**Rabbit Forms** is a complete open-source Form Builder SaaS solution similar to FormBee and Zoho Forms, featuring multi-tenancy, conditional logic, analytics, and advanced form management.

**Tech Stack:**
- **Frontend**: Next.js 14+ (App Router), TypeScript, React 18+
- **UI Library**: shadcn/ui, Radix UI, Tailwind CSS
- **Form Builder**: dnd-kit (drag-and-drop), React Hook Form
- **Rich Text**: Tiptap
- **Backend**: Next.js API Routes, Supabase (PostgreSQL, Auth, Storage)
- **Deployment**: Vercel (Frontend), Supabase (Database + Auth)
- **Email**: Resend or SendGrid
- **Signature**: react-signature-canvas

---

## 1. Core Features

### Super Admin Features
- Create and manage businesses (organizations)
- Assign/revoke business admin accounts
- View platform-wide analytics
- Manage data retention policies
- System configuration

### Business Admin Features
- Create/edit/delete forms
- Visual drag-and-drop form builder
- Conditional logic builder (no-code)
- Database lookup configuration (check existing submissions)
- Custom branding (logo, colors, themes)
- Email notification templates
- CAPTCHA toggle
- Analytics dashboard (submission stats, completion rates)
- Export submissions (CSV, JSON)
- API key management
- Multi-step form configuration
- Signature field configuration

### End User Features (Public)
- Fill out forms (no account required)
- Multi-step form navigation
- Digital signature support
- Auto-save progress (optional)
- Duplicate submission prevention (based on database checks)

---

## 2. Database Schema

### Supabase PostgreSQL Tables

```sql
-- ===========================
-- SUPER ADMIN & BUSINESSES
-- ===========================

CREATE TABLE businesses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL, -- URL-safe identifier
  logo_url TEXT,
  custom_domain TEXT,
  theme JSONB DEFAULT '{"primaryColor": "#3b82f6", "fontFamily": "Inter"}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'business_admin')),
  business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================
-- FORMS & FIELDS
-- ===========================

CREATE TABLE forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  slug TEXT NOT NULL, -- URL-safe identifier
  schema JSONB NOT NULL, -- Form field definitions
  settings JSONB DEFAULT '{}', -- Multi-step, branding, etc.
  conditional_logic JSONB DEFAULT '[]', -- Visual logic rules
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id, slug)
);

-- Index for form lookups
CREATE INDEX idx_forms_business_slug ON forms(business_id, slug);
CREATE INDEX idx_forms_active ON forms(is_active) WHERE is_active = true;

-- ===========================
-- SUBMISSIONS
-- ===========================

CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  data JSONB NOT NULL, -- Form field values
  metadata JSONB DEFAULT '{}', -- IP, user agent, etc.
  signature_url TEXT, -- Supabase Storage URL
  is_duplicate BOOLEAN DEFAULT false,
  duplicate_check_key TEXT, -- e.g., "phone_number" or "email"
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for duplicate checks and queries
CREATE INDEX idx_submissions_form ON submissions(form_id, submitted_at DESC);
CREATE INDEX idx_submissions_business ON submissions(business_id, submitted_at DESC);
CREATE INDEX idx_submissions_duplicate_check ON submissions(form_id, duplicate_check_key, submitted_at DESC);
CREATE INDEX idx_submissions_data_gin ON submissions USING GIN (data); -- For JSONB queries

-- ===========================
-- CONFIGURATION
-- ===========================

CREATE TABLE email_configs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  form_id UUID REFERENCES forms(id) ON DELETE CASCADE, -- NULL = business-wide
  notification_type TEXT NOT NULL CHECK (notification_type IN ('submission', 'welcome', 'duplicate')),
  recipients TEXT[] NOT NULL, -- Email addresses
  subject TEXT NOT NULL,
  body_template TEXT NOT NULL, -- HTML template with placeholders
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE captcha_configs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  form_id UUID REFERENCES forms(id) ON DELETE CASCADE,
  provider TEXT NOT NULL CHECK (provider IN ('recaptcha_v2', 'recaptcha_v3', 'hcaptcha', 'turnstile')),
  site_key TEXT NOT NULL,
  secret_key TEXT NOT NULL, -- Encrypted
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  key_hash TEXT NOT NULL UNIQUE, -- Hashed API key
  key_prefix TEXT NOT NULL, -- First 8 chars for display (e.g., "rfk_12345...")
  permissions JSONB DEFAULT '{"read": true, "write": false}',
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

-- ===========================
-- ANALYTICS & RETENTION
-- ===========================

CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  form_id UUID REFERENCES forms(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN ('view', 'start', 'complete', 'abandon')),
  metadata JSONB DEFAULT '{}',
  session_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_analytics_form_created ON analytics_events(form_id, created_at DESC);
CREATE INDEX idx_analytics_business_created ON analytics_events(business_id, created_at DESC);

CREATE TABLE retention_policies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  retention_days INTEGER NOT NULL DEFAULT 365,
  auto_delete_enabled BOOLEAN DEFAULT false,
  last_cleanup_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id)
);

-- ===========================
-- ROW LEVEL SECURITY (RLS)
-- ===========================

-- Enable RLS on all tables
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE captcha_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE retention_policies ENABLE ROW LEVEL SECURITY;

-- Example RLS Policies (simplified - more detailed policies needed)

-- Super admins can see everything
CREATE POLICY super_admin_all ON businesses
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'super_admin'
    )
  );

-- Business admins can only see their business
CREATE POLICY business_admin_own ON businesses
  FOR SELECT USING (
    id IN (
      SELECT business_id FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'business_admin'
    )
  );

-- Public forms are readable by anyone (for submission)
CREATE POLICY public_forms ON forms
  FOR SELECT USING (is_active = true);

-- Submissions are insertable by anyone (public forms)
CREATE POLICY public_submit ON submissions
  FOR INSERT WITH CHECK (true);
```

---

## 3. File Structure

```
rabbit-forms/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── public/
│   ├── logo.svg
│   └── favicon.ico
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   └── signup/
│   │   │       └── page.tsx
│   │   ├── (super-admin)/
│   │   │   ├── layout.tsx
│   │   │   └── dashboard/
│   │   │       ├── page.tsx
│   │   │       ├── businesses/
│   │   │       │   ├── page.tsx
│   │   │       │   ├── [id]/
│   │   │       │   │   └── page.tsx
│   │   │       │   └── new/
│   │   │       │       └── page.tsx
│   │   │       └── analytics/
│   │   │           └── page.tsx
│   │   ├── (business-admin)/
│   │   │   ├── layout.tsx
│   │   │   └── [businessSlug]/
│   │   │       ├── dashboard/
│   │   │       │   └── page.tsx
│   │   │       ├── forms/
│   │   │       │   ├── page.tsx
│   │   │       │   ├── new/
│   │   │       │   │   └── page.tsx
│   │   │       │   └── [formId]/
│   │   │       │       ├── edit/
│   │   │       │       │   └── page.tsx
│   │   │       │       ├── submissions/
│   │   │       │       │   └── page.tsx
│   │   │       │       └── analytics/
│   │   │       │           └── page.tsx
│   │   │       ├── settings/
│   │   │       │   ├── branding/
│   │   │       │   │   └── page.tsx
│   │   │       │   ├── notifications/
│   │   │       │   │   └── page.tsx
│   │   │       │   ├── api-keys/
│   │   │       │   │   └── page.tsx
│   │   │       │   └── retention/
│   │   │       │       └── page.tsx
│   │   ├── f/
│   │   │   └── [businessSlug]/
│   │   │       └── [formSlug]/
│   │   │           └── page.tsx  # Public form viewer
│   │   ├── api/
│   │   │   ├── auth/
│   │   │   │   └── [...supabase]/
│   │   │   │       └── route.ts
│   │   │   ├── forms/
│   │   │   │   ├── [formId]/
│   │   │   │   │   ├── route.ts
│   │   │   │   │   └── submit/
│   │   │   │   │       └── route.ts
│   │   │   ├── submissions/
│   │   │   │   └── [submissionId]/
│   │   │   │       └── route.ts
│   │   │   ├── analytics/
│   │   │   │   └── route.ts
│   │   │   └── webhook/
│   │   │       └── route.ts
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── ui/  # shadcn components
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── table.tsx
│   │   │   ├── tabs.tsx
│   │   │   └── ...
│   │   ├── form-builder/
│   │   │   ├── FormBuilder.tsx
│   │   │   ├── FieldPalette.tsx
│   │   │   ├── FormCanvas.tsx
│   │   │   ├── FieldEditor.tsx
│   │   │   ├── ConditionalLogicBuilder.tsx
│   │   │   └── field-types/
│   │   │       ├── TextField.tsx
│   │   │       ├── TextAreaField.tsx
│   │   │       ├── SelectField.tsx
│   │   │       ├── RadioField.tsx
│   │   │       ├── CheckboxField.tsx
│   │   │       ├── DateField.tsx
│   │   │       ├── SignatureField.tsx
│   │   │       └── FileUploadField.tsx  # Future
│   │   ├── form-renderer/
│   │   │   ├── FormRenderer.tsx
│   │   │   ├── MultiStepForm.tsx
│   │   │   ├── SinglePageForm.tsx
│   │   │   └── SignaturePad.tsx
│   │   ├── analytics/
│   │   │   ├── DashboardCharts.tsx
│   │   │   ├── SubmissionTable.tsx
│   │   │   └── ExportButton.tsx
│   │   ├── layout/
│   │   │   ├── Navbar.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── Footer.tsx
│   │   └── shared/
│   │       ├── LoadingSpinner.tsx
│   │       ├── ErrorBoundary.tsx
│   │       └── ConfirmDialog.tsx
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts
│   │   │   ├── server.ts
│   │   │   └── middleware.ts
│   │   ├── auth/
│   │   │   ├── session.ts
│   │   │   └── permissions.ts
│   │   ├── email/
│   │   │   ├── resend.ts
│   │   │   └── templates.ts
│   │   ├── validation/
│   │   │   └── schemas.ts  # Zod schemas
│   │   ├── utils/
│   │   │   ├── duplicate-check.ts
│   │   │   ├── conditional-logic.ts
│   │   │   ├── export-csv.ts
│   │   │   └── api-key.ts
│   │   └── hooks/
│   │       ├── useForm.ts
│   │       ├── useSubmissions.ts
│   │       └── useAnalytics.ts
│   ├── types/
│   │   ├── database.ts
│   │   ├── form.ts
│   │   ├── submission.ts
│   │   └── analytics.ts
│   └── styles/
│       └── globals.css
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_functions.sql
│   ├── functions/
│   │   └── cleanup-old-submissions/
│   │       └── index.ts  # Cron job for retention
│   └── config.toml
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── .env.example
├── .env.local
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
├── package.json
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── RABBIT_FORMS_IMPLEMENTATION_PLAN.md
```

---

## 4. Key Features Implementation Details

### 4.1 Form Builder (Drag & Drop)

**Libraries:**
- `@dnd-kit/core` - Drag and drop functionality
- `@dnd-kit/sortable` - Sortable fields
- `react-hook-form` - Form state management

**Field Types:**
1. Text Input (short text)
2. Text Area (long text)
3. Number
4. Email
5. Phone
6. Date/DateTime
7. Dropdown (Select)
8. Radio Buttons
9. Checkboxes
10. Signature (Canvas-based)
11. Section Header
12. Page Break (for multi-step)

**Form Schema (JSON Structure):**
```json
{
  "version": "1.0",
  "fields": [
    {
      "id": "field_123",
      "type": "text",
      "label": "First Name",
      "placeholder": "Enter your first name",
      "required": true,
      "validation": {
        "minLength": 2,
        "maxLength": 50
      }
    },
    {
      "id": "field_456",
      "type": "signature",
      "label": "Your Signature",
      "required": true
    }
  ],
  "settings": {
    "multiStep": true,
    "pages": [
      {
        "title": "Personal Information",
        "fieldIds": ["field_123", "field_456"]
      }
    ],
    "theme": {
      "primaryColor": "#3b82f6"
    }
  }
}
```

### 4.2 Conditional Logic Builder (No-Code)

**Visual Interface:**
- IF-THEN-ELSE rules
- Trigger conditions: field value comparisons
- Actions: Show/Hide fields, Skip to page, Show message

**Logic Schema:**
```json
{
  "rules": [
    {
      "id": "rule_1",
      "trigger": {
        "fieldId": "field_phone",
        "operator": "exists_in_database",
        "table": "submissions",
        "checkField": "data->>'phone'",
        "timeWindow": 30  // days
      },
      "actions": [
        {
          "type": "show_message",
          "message": "You've already submitted this form recently."
        },
        {
          "type": "prevent_submission"
        }
      ]
    },
    {
      "id": "rule_2",
      "trigger": {
        "fieldId": "field_age",
        "operator": "greater_than",
        "value": 18
      },
      "actions": [
        {
          "type": "show_field",
          "fieldId": "field_consent"
        }
      ]
    }
  ]
}
```

### 4.3 Database Duplicate Check

**Implementation:**
```typescript
// lib/utils/duplicate-check.ts
export async function checkDuplicateSubmission(
  formId: string,
  checkField: string,
  checkValue: string,
  timeWindowDays: number
): Promise<{ isDuplicate: boolean; lastSubmission?: Date }> {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - timeWindowDays);

  const { data, error } = await supabase
    .from('submissions')
    .select('submitted_at')
    .eq('form_id', formId)
    .eq('duplicate_check_key', checkValue)
    .gte('submitted_at', cutoffDate.toISOString())
    .order('submitted_at', { ascending: false })
    .limit(1);

  if (error) throw error;

  return {
    isDuplicate: data.length > 0,
    lastSubmission: data[0]?.submitted_at
  };
}
```

### 4.4 Signature Implementation

**Library:** `react-signature-canvas`

**Flow:**
1. User draws signature on canvas
2. Convert to PNG/SVG blob
3. Upload to Supabase Storage (`/signatures/` bucket)
4. Store URL in `submissions.signature_url`

```typescript
// components/form-renderer/SignaturePad.tsx
import SignatureCanvas from 'react-signature-canvas';

export function SignaturePad({ onChange }: { onChange: (url: string) => void }) {
  const sigPad = useRef<SignatureCanvas>(null);

  const handleSave = async () => {
    if (sigPad.current) {
      const dataURL = sigPad.current.toDataURL();
      const blob = dataURLToBlob(dataURL);

      // Upload to Supabase Storage
      const fileName = `signature_${Date.now()}.png`;
      const { data, error } = await supabase.storage
        .from('signatures')
        .upload(fileName, blob);

      if (!error) {
        const { data: { publicUrl } } = supabase.storage
          .from('signatures')
          .getPublicUrl(fileName);
        onChange(publicUrl);
      }
    }
  };

  return (
    <div>
      <SignatureCanvas ref={sigPad} />
      <button onClick={handleSave}>Save Signature</button>
    </div>
  );
}
```

### 4.5 Email Notifications

**Provider:** Resend (free tier: 100 emails/day) or SendGrid

**Template System:**
```typescript
// lib/email/templates.ts
export const submissionTemplate = (data: any) => `
<!DOCTYPE html>
<html>
<body>
  <h1>New Form Submission</h1>
  <p>Form: ${data.formTitle}</p>
  <h2>Submission Details:</h2>
  ${Object.entries(data.fields).map(([key, value]) => `
    <p><strong>${key}:</strong> ${value}</p>
  `).join('')}
</body>
</html>
`;
```

**Configuration Interface:**
- Business admins configure per-form notification rules
- Template editor with placeholders: `{{field_name}}`, `{{submitted_at}}`
- Multiple recipients support

### 4.6 Analytics Dashboard

**Metrics:**
1. Total submissions
2. Completion rate (started vs completed)
3. Average completion time
4. Submissions over time (chart)
5. Field-level drop-off analysis
6. Device/browser breakdown

**Charts:** Use `recharts` or `tremor`

**Export:**
```typescript
// lib/utils/export-csv.ts
export function exportToCSV(submissions: any[], formFields: any[]) {
  const headers = formFields.map(f => f.label);
  const rows = submissions.map(s =>
    formFields.map(f => s.data[f.id] || '')
  );

  const csv = [headers, ...rows]
    .map(row => row.join(','))
    .join('\n');

  return new Blob([csv], { type: 'text/csv' });
}
```

### 4.7 API Access

**Authentication:** API Key (hashed, stored in `api_keys` table)

**Endpoints:**
```
GET    /api/v1/forms/:formId/submissions
POST   /api/v1/forms/:formId/submit
GET    /api/v1/forms/:formId/analytics
DELETE /api/v1/submissions/:submissionId
```

**Rate Limiting:** Use Vercel Edge Config or Upstash Redis

**Example:**
```typescript
// app/api/v1/submissions/route.ts
import { validateApiKey } from '@/lib/utils/api-key';

export async function GET(request: Request) {
  const apiKey = request.headers.get('Authorization')?.replace('Bearer ', '');
  const { valid, businessId } = await validateApiKey(apiKey);

  if (!valid) {
    return Response.json({ error: 'Invalid API key' }, { status: 401 });
  }

  // Fetch submissions for this business...
}
```

### 4.8 CAPTCHA Integration

**Supported Providers:**
- Google reCAPTCHA v2/v3
- hCaptcha
- Cloudflare Turnstile (recommended - free, privacy-friendly)

**Implementation:**
```typescript
// Server-side verification
export async function verifyCaptcha(token: string, secretKey: string) {
  const response = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ secret: secretKey, response: token })
  });

  const data = await response.json();
  return data.success;
}
```

### 4.9 Data Retention

**Cron Job (Supabase Edge Function):**
```typescript
// supabase/functions/cleanup-old-submissions/index.ts
import { createClient } from '@supabase/supabase-js';

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Get all retention policies
  const { data: policies } = await supabase
    .from('retention_policies')
    .select('*')
    .eq('auto_delete_enabled', true);

  for (const policy of policies || []) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - policy.retention_days);

    await supabase
      .from('submissions')
      .delete()
      .eq('business_id', policy.business_id)
      .lt('submitted_at', cutoffDate.toISOString());

    await supabase
      .from('retention_policies')
      .update({ last_cleanup_at: new Date().toISOString() })
      .eq('id', policy.id);
  }

  return new Response('Cleanup complete', { status: 200 });
});
```

**Schedule:** Daily via Supabase Cron or Vercel Cron Jobs

---

## 5. Development Phases

### Phase 1: Foundation (Weeks 1-2)
- [ ] Project setup (Next.js, TypeScript, Tailwind, shadcn/ui)
- [ ] Supabase project setup
- [ ] Database schema implementation
- [ ] RLS policies
- [ ] Authentication (Super Admin, Business Admin)
- [ ] Basic routing structure
- [ ] Super Admin dashboard (create businesses, assign admins)

### Phase 2: Form Builder Core (Weeks 3-4)
- [ ] Form builder UI with drag-and-drop
- [ ] Field types implementation (text, select, radio, checkbox, date)
- [ ] Form schema storage (JSONB in PostgreSQL)
- [ ] Form preview/test mode
- [ ] Business admin dashboard
- [ ] Form CRUD operations

### Phase 3: Form Rendering & Submission (Week 5)
- [ ] Public form renderer
- [ ] Single-page form support
- [ ] Multi-step form support
- [ ] Signature field implementation
- [ ] Form submission API
- [ ] Basic validation

### Phase 4: Conditional Logic & Duplicate Check (Week 6)
- [ ] Visual conditional logic builder
- [ ] Logic engine implementation
- [ ] Database duplicate check functionality
- [ ] Dynamic form behavior (show/hide fields)
- [ ] Time-window based checks

### Phase 5: Analytics & Reporting (Week 7)
- [ ] Analytics event tracking
- [ ] Dashboard charts (submissions over time, completion rate)
- [ ] Submission table/list view
- [ ] CSV export
- [ ] JSON export
- [ ] Field-level analytics

### Phase 6: Email Notifications (Week 8)
- [ ] Email provider integration (Resend/SendGrid)
- [ ] Template system
- [ ] Notification configuration UI
- [ ] Trigger logic (on submission, on duplicate, etc.)
- [ ] Test email functionality

### Phase 7: Customization & Branding (Week 9)
- [ ] Business branding settings (logo, colors)
- [ ] Custom themes per form
- [ ] Theme preview
- [ ] Font customization
- [ ] CSS variable system

### Phase 8: API & Integrations (Week 10)
- [ ] API key management UI
- [ ] API authentication middleware
- [ ] REST API endpoints
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Rate limiting
- [ ] Webhooks (optional)

### Phase 9: Security & Compliance (Week 11)
- [ ] CAPTCHA integration (Turnstile)
- [ ] CAPTCHA configuration UI
- [ ] Rate limiting for public forms
- [ ] Data retention policies UI
- [ ] Automated cleanup cron job
- [ ] Security audit

### Phase 10: Testing & Documentation (Week 12)
- [ ] Unit tests (Jest, React Testing Library)
- [ ] Integration tests
- [ ] E2E tests (Playwright)
- [ ] README documentation
- [ ] CONTRIBUTING.md
- [ ] API documentation
- [ ] Video tutorials

### Phase 11: Polish & Launch (Week 13)
- [ ] UI/UX refinements
- [ ] Performance optimization
- [ ] SEO optimization
- [ ] Error handling improvements
- [ ] Loading states
- [ ] Accessibility audit (WCAG 2.1)
- [ ] Open-source license (MIT)
- [ ] GitHub repository setup
- [ ] Deploy to Vercel

---

## 6. Environment Variables

```bash
# .env.local

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Email (Resend)
RESEND_API_KEY=re_xxxxxxxxxxxx
RESEND_FROM_EMAIL=noreply@yourdomain.com

# CAPTCHA (Cloudflare Turnstile)
NEXT_PUBLIC_TURNSTILE_SITE_KEY=your-site-key
TURNSTILE_SECRET_KEY=your-secret-key

# App Config
NEXT_PUBLIC_APP_URL=https://rabbitforms.com
NEXT_PUBLIC_APP_NAME=Rabbit Forms

# Encryption (for API keys)
ENCRYPTION_KEY=your-32-byte-key
```

---

## 7. Deployment Checklist

### Vercel Configuration
- [ ] Connect GitHub repository
- [ ] Set environment variables
- [ ] Configure build settings (Next.js)
- [ ] Enable preview deployments
- [ ] Set up custom domain

### Supabase Configuration
- [ ] Create production project
- [ ] Run migrations
- [ ] Set up Storage buckets (`signatures`)
- [ ] Configure CORS
- [ ] Set up Edge Functions (cleanup cron)
- [ ] Enable database backups

### DNS & Domain
- [ ] Configure DNS for main domain
- [ ] SSL certificate (auto via Vercel)
- [ ] Set up email domain (for Resend)

---

## 8. Free Tier Limits & Considerations

### Vercel Free Tier
- 100 GB bandwidth/month
- Unlimited deployments
- Serverless function execution: 100 GB-hours/month
- **Mitigation:** Optimize images, use caching, CDN

### Supabase Free Tier
- 500 MB database space
- 1 GB file storage
- 2 GB bandwidth/month
- 50,000 monthly active users
- **Mitigation:**
  - Compress signatures before upload
  - Implement aggressive data retention
  - Use pagination for large datasets
  - Clean up old analytics events

### Resend Free Tier
- 100 emails/day
- 1 domain
- **Mitigation:** Add email quota warnings in admin UI

---

## 9. Open Source Strategy

### GitHub Repository
- **License:** MIT License
- **Structure:**
  - Clear README with setup instructions
  - CONTRIBUTING.md with development guide
  - CODE_OF_CONDUCT.md
  - Issue templates (bug, feature request)
  - PR templates

### Community Features
- GitHub Discussions for Q&A
- Roadmap in GitHub Projects
- Good first issue labels
- Contributor recognition

### Documentation Site (Optional Phase 2)
- Deploy to Vercel (separate project)
- Use Next.js + Nextra
- API reference, guides, tutorials

---

## 10. Future Enhancements (Post-MVP)

1. **File Upload Support** (requires paid Supabase tier)
2. **Payment Integration** (Stripe, PayPal)
3. **Subdomain support** (custom domains per business)
4. **Advanced analytics** (funnel analysis, heatmaps)
5. **Integrations** (Zapier, Make, Webhook management)
6. **Form templates marketplace**
7. **Collaboration features** (team members, roles)
8. **White-label options**
9. **Mobile app** (React Native)
10. **AI-powered form optimization suggestions**

---

## 11. Success Metrics

- [ ] Form creation time < 5 minutes (for simple forms)
- [ ] Form submission response time < 500ms
- [ ] 99%+ uptime
- [ ] Mobile responsiveness (100% features work on mobile)
- [ ] Accessibility score > 95 (Lighthouse)
- [ ] Core Web Vitals: Green
- [ ] GitHub stars > 100 in first month
- [ ] Active contributors > 10 in first 3 months

---

## Next Steps

1. **Review & Approve Plan**
2. **Create GitHub Repository** (public)
3. **Initialize Next.js Project**
4. **Set Up Supabase Project**
5. **Begin Phase 1 Development**

---

**Project Timeline:** 13 weeks (3 months)
**Estimated Effort:** Full-time equivalent
**Risk Level:** Medium (complexity in conditional logic, multi-tenancy)

Let's build Rabbit Forms! 🚀🐰

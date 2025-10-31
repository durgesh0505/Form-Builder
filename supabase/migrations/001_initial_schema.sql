-- ===========================
-- Rabbit Forms - Initial Database Schema
-- Migration: 001
-- Description: Creates all core tables for multi-tenant form builder
-- ===========================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================
-- SUPER ADMIN & BUSINESSES
-- ===========================

CREATE TABLE businesses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL, -- URL-safe identifier
  logo_url TEXT,
  custom_domain TEXT,
  theme JSONB DEFAULT '{"primaryColor": "#3b82f6", "fontFamily": "Inter"}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index for slug lookups
CREATE INDEX idx_businesses_slug ON businesses(slug);
CREATE INDEX idx_businesses_active ON businesses(is_active) WHERE is_active = true;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Users table (extends Supabase auth.users)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'business_admin')),
  business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT business_admin_must_have_business CHECK (
    role = 'super_admin' OR (role = 'business_admin' AND business_id IS NOT NULL)
  )
);

CREATE INDEX idx_users_business ON users(business_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================
-- FORMS & FIELDS
-- ===========================

CREATE TABLE forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  slug TEXT NOT NULL, -- URL-safe identifier
  schema JSONB NOT NULL DEFAULT '{
    "version": "1.0",
    "fields": [],
    "settings": {}
  }'::jsonb, -- Form field definitions
  settings JSONB DEFAULT '{
    "multiStep": false,
    "captchaEnabled": false,
    "allowDuplicates": true
  }'::jsonb,
  conditional_logic JSONB DEFAULT '[]'::jsonb, -- Visual logic rules
  is_active BOOLEAN DEFAULT true,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  UNIQUE(business_id, slug)
);

-- Indexes for form lookups
CREATE INDEX idx_forms_business_slug ON forms(business_id, slug);
CREATE INDEX idx_forms_business_active ON forms(business_id, is_active) WHERE is_active = true;
CREATE INDEX idx_forms_published ON forms(is_published) WHERE is_published = true;
CREATE INDEX idx_forms_created_by ON forms(created_by);

CREATE TRIGGER update_forms_updated_at BEFORE UPDATE ON forms
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================
-- SUBMISSIONS
-- ===========================

CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  data JSONB NOT NULL DEFAULT '{}'::jsonb, -- Form field values
  metadata JSONB DEFAULT '{
    "ip": null,
    "userAgent": null,
    "referrer": null
  }'::jsonb,
  signature_url TEXT, -- Supabase Storage URL
  is_duplicate BOOLEAN DEFAULT false,
  duplicate_check_key TEXT, -- e.g., phone number or email for duplicate detection
  status TEXT DEFAULT 'completed' CHECK (status IN ('draft', 'completed', 'archived')),
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for efficient queries
CREATE INDEX idx_submissions_form ON submissions(form_id, submitted_at DESC);
CREATE INDEX idx_submissions_business ON submissions(business_id, submitted_at DESC);
CREATE INDEX idx_submissions_duplicate_check ON submissions(form_id, duplicate_check_key, submitted_at DESC)
  WHERE duplicate_check_key IS NOT NULL;
CREATE INDEX idx_submissions_data_gin ON submissions USING GIN (data); -- For JSONB queries
CREATE INDEX idx_submissions_status ON submissions(status);

-- ===========================
-- EMAIL CONFIGURATION
-- ===========================

CREATE TABLE email_configs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  form_id UUID REFERENCES forms(id) ON DELETE CASCADE, -- NULL = business-wide default
  notification_type TEXT NOT NULL CHECK (notification_type IN ('submission', 'welcome', 'duplicate', 'admin_notification')),
  recipients TEXT[] NOT NULL, -- Array of email addresses
  subject TEXT NOT NULL,
  body_template TEXT NOT NULL, -- HTML template with placeholders {{field_name}}
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_email_configs_business ON email_configs(business_id);
CREATE INDEX idx_email_configs_form ON email_configs(form_id);
CREATE INDEX idx_email_configs_type ON email_configs(notification_type);

CREATE TRIGGER update_email_configs_updated_at BEFORE UPDATE ON email_configs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================
-- CAPTCHA CONFIGURATION
-- ===========================

CREATE TABLE captcha_configs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  form_id UUID REFERENCES forms(id) ON DELETE CASCADE, -- NULL = business-wide default
  provider TEXT NOT NULL CHECK (provider IN ('recaptcha_v2', 'recaptcha_v3', 'hcaptcha', 'turnstile')),
  site_key TEXT NOT NULL,
  secret_key TEXT NOT NULL, -- Should be encrypted in application layer
  threshold DECIMAL(3,2) DEFAULT 0.5, -- For reCAPTCHA v3 (0.0 to 1.0)
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id, form_id, provider)
);

CREATE INDEX idx_captcha_configs_business ON captcha_configs(business_id);
CREATE INDEX idx_captcha_configs_form ON captcha_configs(form_id);

CREATE TRIGGER update_captcha_configs_updated_at BEFORE UPDATE ON captcha_configs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================
-- API KEYS
-- ===========================

CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  key_hash TEXT NOT NULL UNIQUE, -- SHA-256 hash of the API key
  key_prefix TEXT NOT NULL, -- First 8 chars for display (e.g., "rfk_12345...")
  permissions JSONB DEFAULT '{
    "read": true,
    "write": false,
    "delete": false
  }'::jsonb,
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

CREATE INDEX idx_api_keys_business ON api_keys(business_id);
CREATE INDEX idx_api_keys_hash ON api_keys(key_hash);
CREATE INDEX idx_api_keys_active ON api_keys(is_active) WHERE is_active = true;

-- ===========================
-- ANALYTICS EVENTS
-- ===========================

CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  form_id UUID REFERENCES forms(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN ('view', 'start', 'step_complete', 'complete', 'abandon', 'error')),
  metadata JSONB DEFAULT '{}'::jsonb,
  session_id UUID, -- Track user journey
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for analytics queries
CREATE INDEX idx_analytics_form_created ON analytics_events(form_id, created_at DESC);
CREATE INDEX idx_analytics_business_created ON analytics_events(business_id, created_at DESC);
CREATE INDEX idx_analytics_session ON analytics_events(session_id);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);

-- Partition by month for better performance (optional, uncomment if needed)
-- CREATE TABLE analytics_events_y2025m01 PARTITION OF analytics_events
-- FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- ===========================
-- DATA RETENTION POLICIES
-- ===========================

CREATE TABLE retention_policies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  retention_days INTEGER NOT NULL DEFAULT 365,
  auto_delete_enabled BOOLEAN DEFAULT false,
  delete_submissions BOOLEAN DEFAULT true,
  delete_analytics BOOLEAN DEFAULT true,
  last_cleanup_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id)
);

CREATE INDEX idx_retention_policies_business ON retention_policies(business_id);
CREATE INDEX idx_retention_policies_auto_delete ON retention_policies(auto_delete_enabled)
  WHERE auto_delete_enabled = true;

CREATE TRIGGER update_retention_policies_updated_at BEFORE UPDATE ON retention_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================
-- HELPER FUNCTIONS
-- ===========================

-- Function to check for duplicate submissions
CREATE OR REPLACE FUNCTION check_duplicate_submission(
  p_form_id UUID,
  p_check_value TEXT,
  p_time_window_days INTEGER
) RETURNS TABLE (
  is_duplicate BOOLEAN,
  last_submission_date TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) > 0 AS is_duplicate,
    MAX(submitted_at) AS last_submission_date
  FROM submissions
  WHERE
    form_id = p_form_id
    AND duplicate_check_key = p_check_value
    AND submitted_at >= NOW() - (p_time_window_days || ' days')::INTERVAL;
END;
$$ LANGUAGE plpgsql;

-- Function to get form submission stats
CREATE OR REPLACE FUNCTION get_form_stats(p_form_id UUID)
RETURNS TABLE (
  total_submissions BIGINT,
  total_views BIGINT,
  completion_rate DECIMAL,
  avg_completion_time INTERVAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(DISTINCT s.id) AS total_submissions,
    COUNT(DISTINCT ae.id) FILTER (WHERE ae.event_type = 'view') AS total_views,
    CASE
      WHEN COUNT(DISTINCT ae.id) FILTER (WHERE ae.event_type = 'view') > 0
      THEN (COUNT(DISTINCT s.id)::DECIMAL / COUNT(DISTINCT ae.id) FILTER (WHERE ae.event_type = 'view')::DECIMAL) * 100
      ELSE 0
    END AS completion_rate,
    AVG(s.submitted_at - ae.created_at) FILTER (WHERE ae.event_type = 'start') AS avg_completion_time
  FROM forms f
  LEFT JOIN submissions s ON s.form_id = f.id
  LEFT JOIN analytics_events ae ON ae.form_id = f.id
  WHERE f.id = p_form_id
  GROUP BY f.id;
END;
$$ LANGUAGE plpgsql;

-- ===========================
-- INITIAL DATA
-- ===========================

-- Note: Super admin user should be created via Supabase Auth
-- After signup, insert into users table manually or via trigger

-- Example: Create a default super admin (replace with actual auth.users id)
-- INSERT INTO users (id, email, full_name, role)
-- VALUES (
--   'uuid-from-auth-users',
--   'admin@rabbitforms.com',
--   'Super Admin',
--   'super_admin'
-- );

-- ===========================
-- COMMENTS
-- ===========================

COMMENT ON TABLE businesses IS 'Organizations/tenants that use Rabbit Forms';
COMMENT ON TABLE users IS 'Super admins and business admins (extends auth.users)';
COMMENT ON TABLE forms IS 'Form definitions with schema and settings';
COMMENT ON TABLE submissions IS 'Form submissions from end users';
COMMENT ON TABLE email_configs IS 'Email notification configurations';
COMMENT ON TABLE captcha_configs IS 'CAPTCHA provider configurations';
COMMENT ON TABLE api_keys IS 'API keys for programmatic access';
COMMENT ON TABLE analytics_events IS 'User interaction tracking events';
COMMENT ON TABLE retention_policies IS 'Data retention and cleanup policies';

COMMENT ON COLUMN forms.schema IS 'JSONB containing field definitions, validation rules, and form structure';
COMMENT ON COLUMN forms.conditional_logic IS 'JSONB array of IF-THEN rules for dynamic form behavior';
COMMENT ON COLUMN submissions.data IS 'JSONB containing all form field values';
COMMENT ON COLUMN submissions.duplicate_check_key IS 'Value used for duplicate detection (e.g., phone number)';
COMMENT ON COLUMN api_keys.key_hash IS 'SHA-256 hash of the API key for secure storage';

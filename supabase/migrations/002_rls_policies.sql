-- ===========================
-- Rabbit Forms - Row Level Security Policies
-- Migration: 002
-- Description: Implements RLS policies for multi-tenant security
-- ===========================

-- ===========================
-- ENABLE ROW LEVEL SECURITY
-- ===========================

ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE captcha_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE retention_policies ENABLE ROW LEVEL SECURITY;

-- ===========================
-- HELPER FUNCTION FOR ROLE CHECKS
-- ===========================

-- Get current user's role
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Get current user's business_id
CREATE OR REPLACE FUNCTION get_user_business_id()
RETURNS UUID AS $$
  SELECT business_id FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Check if user is super admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role = 'super_admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- Check if user is business admin for a specific business
CREATE OR REPLACE FUNCTION is_business_admin(business_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND business_id = business_uuid
    AND role = 'business_admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- ===========================
-- BUSINESSES POLICIES
-- ===========================

-- Super admins can do everything with businesses
CREATE POLICY super_admin_businesses_all ON businesses
  FOR ALL
  USING (is_super_admin())
  WITH CHECK (is_super_admin());

-- Business admins can view their own business
CREATE POLICY business_admin_view_own ON businesses
  FOR SELECT
  USING (
    id IN (
      SELECT business_id FROM users
      WHERE id = auth.uid()
      AND role = 'business_admin'
    )
  );

-- Business admins can update their own business (limited fields)
CREATE POLICY business_admin_update_own ON businesses
  FOR UPDATE
  USING (is_business_admin(id))
  WITH CHECK (is_business_admin(id));

-- ===========================
-- USERS POLICIES
-- ===========================

-- Super admins can manage all users
CREATE POLICY super_admin_users_all ON users
  FOR ALL
  USING (is_super_admin())
  WITH CHECK (is_super_admin());

-- Business admins can view users in their business
CREATE POLICY business_admin_view_own_users ON users
  FOR SELECT
  USING (
    business_id = get_user_business_id()
  );

-- Users can view their own profile
CREATE POLICY users_view_self ON users
  FOR SELECT
  USING (id = auth.uid());

-- Users can update their own profile (limited)
CREATE POLICY users_update_self ON users
  FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- ===========================
-- FORMS POLICIES
-- ===========================

-- Super admins can view all forms
CREATE POLICY super_admin_forms_view ON forms
  FOR SELECT
  USING (is_super_admin());

-- Business admins can manage their business's forms
CREATE POLICY business_admin_forms_all ON forms
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- Public can view published forms (for submission)
CREATE POLICY public_view_published_forms ON forms
  FOR SELECT
  USING (is_active = true AND is_published = true);

-- ===========================
-- SUBMISSIONS POLICIES
-- ===========================

-- Super admins can view all submissions
CREATE POLICY super_admin_submissions_view ON submissions
  FOR SELECT
  USING (is_super_admin());

-- Business admins can view/manage their business's submissions
CREATE POLICY business_admin_submissions_all ON submissions
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- Public can insert submissions (for public forms)
CREATE POLICY public_insert_submissions ON submissions
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM forms
      WHERE forms.id = form_id
      AND forms.is_active = true
      AND forms.is_published = true
    )
  );

-- Note: Public cannot read submissions (privacy)

-- ===========================
-- EMAIL CONFIGS POLICIES
-- ===========================

-- Super admins can view all email configs
CREATE POLICY super_admin_email_configs_view ON email_configs
  FOR SELECT
  USING (is_super_admin());

-- Business admins can manage their email configs
CREATE POLICY business_admin_email_configs_all ON email_configs
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- ===========================
-- CAPTCHA CONFIGS POLICIES
-- ===========================

-- Super admins can view all captcha configs
CREATE POLICY super_admin_captcha_configs_view ON captcha_configs
  FOR SELECT
  USING (is_super_admin());

-- Business admins can manage their captcha configs
CREATE POLICY business_admin_captcha_configs_all ON captcha_configs
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- Public can read captcha site keys (needed for form rendering)
CREATE POLICY public_read_captcha_site_keys ON captcha_configs
  FOR SELECT
  USING (
    is_enabled = true
    AND (
      form_id IN (
        SELECT id FROM forms
        WHERE is_active = true AND is_published = true
      )
      OR form_id IS NULL
    )
  );

-- ===========================
-- API KEYS POLICIES
-- ===========================

-- Super admins can view all API keys
CREATE POLICY super_admin_api_keys_view ON api_keys
  FOR SELECT
  USING (is_super_admin());

-- Business admins can manage their API keys
CREATE POLICY business_admin_api_keys_all ON api_keys
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- ===========================
-- ANALYTICS EVENTS POLICIES
-- ===========================

-- Super admins can view all analytics
CREATE POLICY super_admin_analytics_view ON analytics_events
  FOR SELECT
  USING (is_super_admin());

-- Business admins can view/insert their analytics
CREATE POLICY business_admin_analytics_all ON analytics_events
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- Public can insert analytics events (for tracking)
CREATE POLICY public_insert_analytics ON analytics_events
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM forms
      WHERE forms.id = form_id
      AND forms.is_active = true
      AND forms.is_published = true
    )
  );

-- ===========================
-- RETENTION POLICIES
-- ===========================

-- Super admins can view all retention policies
CREATE POLICY super_admin_retention_view ON retention_policies
  FOR SELECT
  USING (is_super_admin());

-- Business admins can manage their retention policies
CREATE POLICY business_admin_retention_all ON retention_policies
  FOR ALL
  USING (business_id = get_user_business_id())
  WITH CHECK (business_id = get_user_business_id());

-- ===========================
-- ADDITIONAL SECURITY
-- ===========================

-- Prevent regular users from escalating privileges
CREATE OR REPLACE FUNCTION prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
  -- Only super admins can create other super admins
  IF NEW.role = 'super_admin' AND NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only super admins can create other super admins';
  END IF;

  -- Only super admins can change roles
  IF TG_OP = 'UPDATE' AND OLD.role != NEW.role AND NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only super admins can change user roles';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER enforce_role_escalation_prevention
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION prevent_role_escalation();

-- Ensure business_id is set correctly for business admins
CREATE OR REPLACE FUNCTION enforce_business_admin_business_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'business_admin' AND NEW.business_id IS NULL THEN
    RAISE EXCEPTION 'Business admins must have a business_id';
  END IF;

  IF NEW.role = 'super_admin' AND NEW.business_id IS NOT NULL THEN
    RAISE EXCEPTION 'Super admins cannot have a business_id';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_business_admin_business_id_trigger
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION enforce_business_admin_business_id();

-- Auto-set business_id for forms, submissions, etc.
CREATE OR REPLACE FUNCTION auto_set_business_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.business_id IS NULL THEN
    NEW.business_id := get_user_business_id();
  END IF;

  -- Verify user has access to this business
  IF NEW.business_id != get_user_business_id() AND NOT is_super_admin() THEN
    RAISE EXCEPTION 'Access denied to this business';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply to forms
CREATE TRIGGER auto_set_forms_business_id
  BEFORE INSERT ON forms
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_business_id();

-- ===========================
-- GRANTS
-- ===========================

-- Grant usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;

-- Grant select on all tables to authenticated users (RLS handles authorization)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- Grant limited access to anonymous users (for public form submissions)
GRANT SELECT ON forms TO anon;
GRANT INSERT ON submissions TO anon;
GRANT INSERT ON analytics_events TO anon;
GRANT SELECT ON captcha_configs TO anon;

-- ===========================
-- COMMENTS
-- ===========================

COMMENT ON POLICY super_admin_businesses_all ON businesses IS 'Super admins have full access to all businesses';
COMMENT ON POLICY business_admin_view_own ON businesses IS 'Business admins can view their own business';
COMMENT ON POLICY public_view_published_forms ON forms IS 'Anonymous users can view published forms for submission';
COMMENT ON POLICY public_insert_submissions ON submissions IS 'Anonymous users can submit forms without authentication';

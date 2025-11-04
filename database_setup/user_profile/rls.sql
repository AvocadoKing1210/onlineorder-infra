-- Row-Level Security Policies for user_profile
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (read all), Users (read/update own)
-- Uses Auth0 JWT 'sub' claim for user identification
--
-- NOTE: Auth0 post-user-registration action should use Supabase service_role key
-- to insert profiles. Service_role key bypasses RLS, so no policy needed for inserts.
-- Store service_role key as Auth0 Action secret for secure access.

-- Helper function to get Auth0 user ID from JWT
CREATE OR REPLACE FUNCTION jwt_user_id()
RETURNS TEXT AS $$
BEGIN
    RETURN auth.jwt() ->> 'sub';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS
ALTER TABLE user_profile ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON user_profile
    FOR SELECT
    TO authenticated
    USING (id = jwt_user_id());

-- Policy: Admin can read all profiles
CREATE POLICY "Admin can read all profiles"
    ON user_profile
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can read all profiles
-- (needed for staff management in owner portal)
CREATE POLICY "Business Owner can read all profiles"
    ON user_profile
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert any profile
CREATE POLICY "Admin can insert any profile"
    ON user_profile
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON user_profile
    FOR UPDATE
    TO authenticated
    USING (id = jwt_user_id())
    WITH CHECK (id = jwt_user_id());

-- Policy: Admin can update any profile
CREATE POLICY "Admin can update any profile"
    ON user_profile
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Admin can delete any profile
CREATE POLICY "Admin can delete any profile"
    ON user_profile
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


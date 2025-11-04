-- Row-Level Security Policies for restaurant_settings
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (select/update), Customer (no access)

-- Helper function to check if JWT user_group array contains a role
CREATE OR REPLACE FUNCTION jwt_has_user_group(required_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(auth.jwt() -> 'user_group') AS role
        WHERE role = required_role
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS
ALTER TABLE restaurant_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Admin can read restaurant settings (full access)
CREATE POLICY "Admin can read restaurant settings"
    ON restaurant_settings
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can read restaurant settings
CREATE POLICY "Business Owner can read restaurant settings"
    ON restaurant_settings
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert restaurant settings
-- (typically only one row exists, created during setup)
CREATE POLICY "Admin can insert restaurant settings"
    ON restaurant_settings
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Admin can update restaurant settings
CREATE POLICY "Admin can update restaurant settings"
    ON restaurant_settings
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update restaurant settings
CREATE POLICY "Business Owner can update restaurant settings"
    ON restaurant_settings
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete restaurant settings
CREATE POLICY "Admin can delete restaurant settings"
    ON restaurant_settings
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


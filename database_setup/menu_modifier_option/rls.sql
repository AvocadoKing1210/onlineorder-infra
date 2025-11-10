-- Row-Level Security Policies for menu_modifier_option
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read visible and available only)

-- Enable RLS
ALTER TABLE menu_modifier_option ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read visible and available options
CREATE POLICY "Anonymous users can read available options"
    ON menu_modifier_option
    FOR SELECT
    TO anon
    USING (
        visible = true
        AND available = true
        AND EXISTS (
            SELECT 1 FROM menu_modifier_group mg
            WHERE mg.id = menu_modifier_option.modifier_group_id
              AND mg.visible = true
        )
    );

-- Policy: Customers can read visible and available options
CREATE POLICY "Customers can read available options"
    ON menu_modifier_option
    FOR SELECT
    TO authenticated
    USING (
        visible = true
        AND available = true
        AND EXISTS (
            SELECT 1 FROM menu_modifier_group mg
            WHERE mg.id = menu_modifier_option.modifier_group_id
              AND mg.visible = true
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all options
CREATE POLICY "Business Owner can read all options"
    ON menu_modifier_option
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all options
CREATE POLICY "Admin can read all options"
    ON menu_modifier_option
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert options
CREATE POLICY "Business Owner can insert options"
    ON menu_modifier_option
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert options
CREATE POLICY "Admin can insert options"
    ON menu_modifier_option
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update options
CREATE POLICY "Business Owner can update options"
    ON menu_modifier_option
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update options
CREATE POLICY "Admin can update options"
    ON menu_modifier_option
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete options
CREATE POLICY "Business Owner can delete options"
    ON menu_modifier_option
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete options
CREATE POLICY "Admin can delete options"
    ON menu_modifier_option
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


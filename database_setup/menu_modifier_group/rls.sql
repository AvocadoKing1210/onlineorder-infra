-- Row-Level Security Policies for menu_modifier_group
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read visible only)

-- Enable RLS
ALTER TABLE menu_modifier_group ENABLE ROW LEVEL SECURITY;

-- Policy: Customers can read visible modifier groups
CREATE POLICY "Customers can read visible modifier groups"
    ON menu_modifier_group
    FOR SELECT
    TO authenticated
    USING (
        visible = true
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all modifier groups
CREATE POLICY "Business Owner can read all modifier groups"
    ON menu_modifier_group
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all modifier groups
CREATE POLICY "Admin can read all modifier groups"
    ON menu_modifier_group
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert modifier groups
CREATE POLICY "Business Owner can insert modifier groups"
    ON menu_modifier_group
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert modifier groups
CREATE POLICY "Admin can insert modifier groups"
    ON menu_modifier_group
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update modifier groups
CREATE POLICY "Business Owner can update modifier groups"
    ON menu_modifier_group
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update modifier groups
CREATE POLICY "Admin can update modifier groups"
    ON menu_modifier_group
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete modifier groups
CREATE POLICY "Business Owner can delete modifier groups"
    ON menu_modifier_group
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete modifier groups
CREATE POLICY "Admin can delete modifier groups"
    ON menu_modifier_group
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


-- Row-Level Security Policies for menu_category
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read visible only)

-- Enable RLS
ALTER TABLE menu_category ENABLE ROW LEVEL SECURITY;

-- Policy: Customers can read visible categories
CREATE POLICY "Customers can read visible categories"
    ON menu_category
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

-- Policy: Business Owner can read all categories (including hidden ones)
CREATE POLICY "Business Owner can read all categories"
    ON menu_category
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all categories
CREATE POLICY "Admin can read all categories"
    ON menu_category
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert categories
CREATE POLICY "Business Owner can insert categories"
    ON menu_category
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert categories
CREATE POLICY "Admin can insert categories"
    ON menu_category
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update categories
CREATE POLICY "Business Owner can update categories"
    ON menu_category
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update categories
CREATE POLICY "Admin can update categories"
    ON menu_category
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete categories
CREATE POLICY "Business Owner can delete categories"
    ON menu_category
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete categories
CREATE POLICY "Admin can delete categories"
    ON menu_category
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


-- Row-Level Security Policies for promotion_category
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read via active promotions only)

-- Enable RLS
ALTER TABLE promotion_category ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read categories for active promotions
CREATE POLICY "Anonymous users can read categories for active promotions"
    ON promotion_category
    FOR SELECT
    TO anon
    USING (
        EXISTS (
            SELECT 1 FROM promotion p
            WHERE p.id = promotion_category.promotion_id
              AND p.active_from <= NOW()
              AND (p.active_until IS NULL OR p.active_until > NOW())
        )
        AND EXISTS (
            SELECT 1 FROM menu_category mc
            WHERE mc.id = promotion_category.category_id
              AND mc.visible = true
        )
    );

-- Policy: Customers can read categories for active promotions
CREATE POLICY "Customers can read categories for active promotions"
    ON promotion_category
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM promotion p
            WHERE p.id = promotion_category.promotion_id
              AND p.active_from <= NOW()
              AND (p.active_until IS NULL OR p.active_until > NOW())
        )
        AND EXISTS (
            SELECT 1 FROM menu_category mc
            WHERE mc.id = promotion_category.category_id
              AND mc.visible = true
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all promotion categories
CREATE POLICY "Business Owner can read all promotion categories"
    ON promotion_category
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all promotion categories
CREATE POLICY "Admin can read all promotion categories"
    ON promotion_category
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert promotion categories
CREATE POLICY "Business Owner can insert promotion categories"
    ON promotion_category
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert promotion categories
CREATE POLICY "Admin can insert promotion categories"
    ON promotion_category
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update promotion categories
CREATE POLICY "Business Owner can update promotion categories"
    ON promotion_category
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update promotion categories
CREATE POLICY "Admin can update promotion categories"
    ON promotion_category
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete promotion categories
CREATE POLICY "Business Owner can delete promotion categories"
    ON promotion_category
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete promotion categories
CREATE POLICY "Admin can delete promotion categories"
    ON promotion_category
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


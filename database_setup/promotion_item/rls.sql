-- Row-Level Security Policies for promotion_item
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read via active promotions only)

-- Enable RLS
ALTER TABLE promotion_item ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read items for active promotions
CREATE POLICY "Anonymous users can read items for active promotions"
    ON promotion_item
    FOR SELECT
    TO anon
    USING (
        EXISTS (
            SELECT 1 FROM promotion p
            WHERE p.id = promotion_item.promotion_id
              AND p.active_from <= NOW()
              AND (p.active_until IS NULL OR p.active_until > NOW())
        )
        AND EXISTS (
            SELECT 1 FROM menu_item mi
            WHERE mi.id = promotion_item.menu_item_id
              AND mi.visible = true
              AND EXISTS (
                  SELECT 1 FROM menu_category mc
                  WHERE mc.id = mi.category_id
                    AND mc.visible = true
              )
        )
    );

-- Policy: Customers can read items for active promotions
CREATE POLICY "Customers can read items for active promotions"
    ON promotion_item
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM promotion p
            WHERE p.id = promotion_item.promotion_id
              AND p.active_from <= NOW()
              AND (p.active_until IS NULL OR p.active_until > NOW())
        )
        AND EXISTS (
            SELECT 1 FROM menu_item mi
            WHERE mi.id = promotion_item.menu_item_id
              AND mi.visible = true
              AND EXISTS (
                  SELECT 1 FROM menu_category mc
                  WHERE mc.id = mi.category_id
                    AND mc.visible = true
              )
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all promotion items
CREATE POLICY "Business Owner can read all promotion items"
    ON promotion_item
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all promotion items
CREATE POLICY "Admin can read all promotion items"
    ON promotion_item
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert promotion items
CREATE POLICY "Business Owner can insert promotion items"
    ON promotion_item
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert promotion items
CREATE POLICY "Admin can insert promotion items"
    ON promotion_item
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update promotion items
CREATE POLICY "Business Owner can update promotion items"
    ON promotion_item
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update promotion items
CREATE POLICY "Admin can update promotion items"
    ON promotion_item
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete promotion items
CREATE POLICY "Business Owner can delete promotion items"
    ON promotion_item
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete promotion items
CREATE POLICY "Admin can delete promotion items"
    ON promotion_item
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


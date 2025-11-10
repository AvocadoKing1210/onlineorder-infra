-- Row-Level Security Policies for menu_item
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read visible only)

-- Enable RLS
ALTER TABLE menu_item ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read visible items
CREATE POLICY "Anonymous users can read visible items"
    ON menu_item
    FOR SELECT
    TO anon
    USING (
        visible = true
        AND EXISTS (
            SELECT 1 FROM menu_category mc
            WHERE mc.id = menu_item.category_id
              AND mc.visible = true
        )
    );

-- Policy: Customers can read visible items
CREATE POLICY "Customers can read visible items"
    ON menu_item
    FOR SELECT
    TO authenticated
    USING (
        visible = true
        AND EXISTS (
            SELECT 1 FROM menu_category mc
            WHERE mc.id = menu_item.category_id
              AND mc.visible = true
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all items
CREATE POLICY "Business Owner can read all items"
    ON menu_item
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all items
CREATE POLICY "Admin can read all items"
    ON menu_item
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert items
CREATE POLICY "Business Owner can insert items"
    ON menu_item
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert items
CREATE POLICY "Admin can insert items"
    ON menu_item
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update items
CREATE POLICY "Business Owner can update items"
    ON menu_item
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update items
CREATE POLICY "Admin can update items"
    ON menu_item
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete items
CREATE POLICY "Business Owner can delete items"
    ON menu_item
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete items
CREATE POLICY "Admin can delete items"
    ON menu_item
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));



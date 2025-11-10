-- Row-Level Security Policies for menu_item_modifier_group
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read only, via visible items/groups)

-- Enable RLS
ALTER TABLE menu_item_modifier_group ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read associations for visible items and groups
CREATE POLICY "Anonymous users can read visible associations"
    ON menu_item_modifier_group
    FOR SELECT
    TO anon
    USING (
        EXISTS (
            SELECT 1 FROM menu_item mi
            WHERE mi.id = menu_item_modifier_group.menu_item_id
              AND mi.visible = true
              AND EXISTS (
                  SELECT 1 FROM menu_category mc
                  WHERE mc.id = mi.category_id
                    AND mc.visible = true
              )
        )
        AND EXISTS (
            SELECT 1 FROM menu_modifier_group mg
            WHERE mg.id = menu_item_modifier_group.modifier_group_id
              AND mg.visible = true
        )
    );

-- Policy: Customers can read associations for visible items and groups
CREATE POLICY "Customers can read visible associations"
    ON menu_item_modifier_group
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM menu_item mi
            WHERE mi.id = menu_item_modifier_group.menu_item_id
              AND mi.visible = true
              AND EXISTS (
                  SELECT 1 FROM menu_category mc
                  WHERE mc.id = mi.category_id
                    AND mc.visible = true
              )
        )
        AND EXISTS (
            SELECT 1 FROM menu_modifier_group mg
            WHERE mg.id = menu_item_modifier_group.modifier_group_id
              AND mg.visible = true
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all associations
CREATE POLICY "Business Owner can read all associations"
    ON menu_item_modifier_group
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all associations
CREATE POLICY "Admin can read all associations"
    ON menu_item_modifier_group
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert associations
CREATE POLICY "Business Owner can insert associations"
    ON menu_item_modifier_group
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert associations
CREATE POLICY "Admin can insert associations"
    ON menu_item_modifier_group
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update associations
CREATE POLICY "Business Owner can update associations"
    ON menu_item_modifier_group
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update associations
CREATE POLICY "Admin can update associations"
    ON menu_item_modifier_group
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete associations
CREATE POLICY "Business Owner can delete associations"
    ON menu_item_modifier_group
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete associations
CREATE POLICY "Admin can delete associations"
    ON menu_item_modifier_group
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


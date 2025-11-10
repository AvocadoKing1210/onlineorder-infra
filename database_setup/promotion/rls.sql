-- Row-Level Security Policies for promotion
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read active only)

-- Helper function to check if promotion is currently active
CREATE OR REPLACE FUNCTION promotion_is_active(promo_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM promotion p
        WHERE p.id = promo_id
          AND p.active_from <= NOW()
          AND (p.active_until IS NULL OR p.active_until > NOW())
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS
ALTER TABLE promotion ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read active promotions
CREATE POLICY "Anonymous users can read active promotions"
    ON promotion
    FOR SELECT
    TO anon
    USING (
        active_from <= NOW()
        AND (active_until IS NULL OR active_until > NOW())
    );

-- Policy: Customers can read active promotions
CREATE POLICY "Customers can read active promotions"
    ON promotion
    FOR SELECT
    TO authenticated
    USING (
        active_from <= NOW()
        AND (active_until IS NULL OR active_until > NOW())
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all promotions
CREATE POLICY "Business Owner can read all promotions"
    ON promotion
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all promotions
CREATE POLICY "Admin can read all promotions"
    ON promotion
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert promotions
CREATE POLICY "Business Owner can insert promotions"
    ON promotion
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert promotions
CREATE POLICY "Admin can insert promotions"
    ON promotion
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update promotions
CREATE POLICY "Business Owner can update promotions"
    ON promotion
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update promotions
CREATE POLICY "Admin can update promotions"
    ON promotion
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete promotions
CREATE POLICY "Business Owner can delete promotions"
    ON promotion
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete promotions
CREATE POLICY "Admin can delete promotions"
    ON promotion
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


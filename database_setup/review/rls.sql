-- Row-Level Security Policies for review
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (own reviews, can read approved reviews)

ALTER TABLE review ENABLE ROW LEVEL SECURITY;

-- Policy: Customers can read their own reviews (all statuses)
CREATE POLICY "Customers can read own reviews"
    ON review
    FOR SELECT
    TO authenticated
    USING (
        user_id = jwt_user_id()
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Anonymous users (guests) can read approved reviews
CREATE POLICY "Anonymous users can read approved reviews"
    ON review
    FOR SELECT
    TO anon
    USING (status = 'approved');

-- Policy: Customers can read approved reviews (for any menu item)
CREATE POLICY "Customers can read approved reviews"
    ON review
    FOR SELECT
    TO authenticated
    USING (
        status = 'approved'
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all reviews
CREATE POLICY "Business Owner can read all reviews"
    ON review
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all reviews
CREATE POLICY "Admin can read all reviews"
    ON review
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Customers can insert their own reviews
CREATE POLICY "Customers can insert own reviews"
    ON review
    FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = jwt_user_id()
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
        AND status = 'pending' -- Reviews must start as pending (moderation happens externally)
    );

-- Policy: Business Owner can insert reviews
CREATE POLICY "Business Owner can insert reviews"
    ON review
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert reviews
CREATE POLICY "Admin can insert reviews"
    ON review
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Customers can update their own reviews (only if still pending)
CREATE POLICY "Customers can update own pending reviews"
    ON review
    FOR UPDATE
    TO authenticated
    USING (
        user_id = jwt_user_id()
        AND status = 'pending' -- Only allow updates to pending reviews
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    )
    WITH CHECK (
        user_id = jwt_user_id()
        AND status = 'pending' -- Status must remain pending (moderation handled externally)
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can update all reviews (for moderation status changes)
CREATE POLICY "Business Owner can update all reviews"
    ON review
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update all reviews
CREATE POLICY "Admin can update all reviews"
    ON review
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Customers can delete their own reviews (only if pending)
CREATE POLICY "Customers can delete own pending reviews"
    ON review
    FOR DELETE
    TO authenticated
    USING (
        user_id = jwt_user_id()
        AND status = 'pending' -- Only allow deletion of pending reviews
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can delete reviews
CREATE POLICY "Business Owner can delete reviews"
    ON review
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete reviews
CREATE POLICY "Admin can delete reviews"
    ON review
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


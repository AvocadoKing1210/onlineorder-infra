-- Row-Level Security Policies for order
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (own orders only)
-- Designed to support Supabase Realtime subscriptions

ALTER TABLE "order" ENABLE ROW LEVEL SECURITY;

-- Policy: Customers can read their own orders
CREATE POLICY "Customers can read own orders"
    ON "order"
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

-- Policy: Business Owner can read all orders
CREATE POLICY "Business Owner can read all orders"
    ON "order"
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all orders
CREATE POLICY "Admin can read all orders"
    ON "order"
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Customers can insert their own orders
CREATE POLICY "Customers can insert own orders"
    ON "order"
    FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = jwt_user_id()
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
        AND status IN ('created', 'submitted') -- Can only create orders in initial states
    );

-- Policy: Customers can update their own orders
-- Note: Status transition validation is enforced by validate_order_status_transition() trigger
-- The trigger ensures customers can only submit orders (created → submitted), not cancel them
CREATE POLICY "Customers can update own orders"
    ON "order"
    FOR UPDATE
    TO authenticated
    USING (
        user_id = jwt_user_id()
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    )
    WITH CHECK (
        user_id = jwt_user_id()
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can update all orders (status transitions, wait times, etc.)
CREATE POLICY "Business Owner can update all orders"
    ON "order"
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update all orders
CREATE POLICY "Admin can update all orders"
    ON "order"
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete orders (for data cleanup)
CREATE POLICY "Business Owner can delete orders"
    ON "order"
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete orders
CREATE POLICY "Admin can delete orders"
    ON "order"
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


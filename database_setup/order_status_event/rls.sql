-- Row-Level Security Policies for order_status_event
-- Uses Auth0 JWT claims with user_group array
-- Access is inherited from the parent order
-- Events are immutable (insert-only)

ALTER TABLE order_status_event ENABLE ROW LEVEL SECURITY;

-- Policy: Customers can read events from their own orders
CREATE POLICY "Customers can read own order status events"
    ON order_status_event
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_status_event.order_id
              AND o.user_id = jwt_user_id()
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all order status events
CREATE POLICY "Business Owner can read all order status events"
    ON order_status_event
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all order status events
CREATE POLICY "Admin can read all order status events"
    ON order_status_event
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Customers can insert events for their own orders (for status changes like cancellation)
CREATE POLICY "Customers can insert own order status events"
    ON order_status_event
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_status_event.order_id
              AND o.user_id = jwt_user_id()
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
        AND (
            actor_type = 'user'
            OR actor_type = 'system'
        )
        AND (
            actor_id IS NULL
            OR actor_id = jwt_user_id()
        )
    );

-- Policy: Business Owner can insert order status events
CREATE POLICY "Business Owner can insert order status events"
    ON order_status_event
    FOR INSERT
    TO authenticated
    WITH CHECK (
        jwt_has_user_group('Business Owner')
        AND (
            actor_type = 'staff'
            OR actor_type = 'system'
        )
        AND (
            actor_id IS NULL
            OR actor_id = jwt_user_id()
        )
    );

-- Policy: Admin can insert order status events
CREATE POLICY "Admin can insert order status events"
    ON order_status_event
    FOR INSERT
    TO authenticated
    WITH CHECK (
        jwt_has_user_group('Admin')
        AND (
            actor_type = 'staff'
            OR actor_type = 'system'
        )
        AND (
            actor_id IS NULL
            OR actor_id = jwt_user_id()
        )
    );

-- Note: No UPDATE or DELETE policies - audit events are immutable


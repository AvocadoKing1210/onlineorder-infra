-- Row-Level Security Policies for order_item_modifier
-- Uses Auth0 JWT claims with user_group array
-- Access is inherited from the parent order_item and order

ALTER TABLE order_item_modifier ENABLE ROW LEVEL SECURITY;

-- Policy: Customers can read modifiers from their own orders
CREATE POLICY "Customers can read own order item modifiers"
    ON order_item_modifier
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM order_item oi
            JOIN "order" o ON o.id = oi.order_id
            WHERE oi.id = order_item_modifier.order_item_id
              AND o.user_id = jwt_user_id()
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all order item modifiers
CREATE POLICY "Business Owner can read all order item modifiers"
    ON order_item_modifier
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all order item modifiers
CREATE POLICY "Admin can read all order item modifiers"
    ON order_item_modifier
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Customers can insert modifiers to their own order items (only before submission)
CREATE POLICY "Customers can insert own order item modifiers"
    ON order_item_modifier
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM order_item oi
            JOIN "order" o ON o.id = oi.order_id
            WHERE oi.id = order_item_modifier.order_item_id
              AND o.user_id = jwt_user_id()
              AND o.status = 'created' -- Only allow adding modifiers before submission
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can insert order item modifiers
CREATE POLICY "Business Owner can insert order item modifiers"
    ON order_item_modifier
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert order item modifiers
CREATE POLICY "Admin can insert order item modifiers"
    ON order_item_modifier
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Customers can update modifiers in their own orders (only before submission)
CREATE POLICY "Customers can update own order item modifiers"
    ON order_item_modifier
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM order_item oi
            JOIN "order" o ON o.id = oi.order_id
            WHERE oi.id = order_item_modifier.order_item_id
              AND o.user_id = jwt_user_id()
              AND o.status = 'created' -- Only allow updates before submission
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM order_item oi
            JOIN "order" o ON o.id = oi.order_id
            WHERE oi.id = order_item_modifier.order_item_id
              AND o.user_id = jwt_user_id()
              AND o.status = 'created'
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can update order item modifiers
CREATE POLICY "Business Owner can update order item modifiers"
    ON order_item_modifier
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update order item modifiers
CREATE POLICY "Admin can update order item modifiers"
    ON order_item_modifier
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Customers can delete modifiers from their own orders (only before submission)
CREATE POLICY "Customers can delete own order item modifiers"
    ON order_item_modifier
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM order_item oi
            JOIN "order" o ON o.id = oi.order_id
            WHERE oi.id = order_item_modifier.order_item_id
              AND o.user_id = jwt_user_id()
              AND o.status = 'created' -- Only allow deletion before submission
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can delete order item modifiers
CREATE POLICY "Business Owner can delete order item modifiers"
    ON order_item_modifier
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete order item modifiers
CREATE POLICY "Admin can delete order item modifiers"
    ON order_item_modifier
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


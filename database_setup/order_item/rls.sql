-- Row-Level Security Policies for order_item
-- Uses Auth0 JWT claims with user_group array
-- Access is inherited from the parent order

ALTER TABLE order_item ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read order items by reference number
-- This enables guest checkout: guests can view order items for their orders
CREATE POLICY "Anonymous users can read order items by reference"
    ON order_item
    FOR SELECT
    TO anon
    USING (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
              AND o.reference_number IS NOT NULL
        )
    );

-- Policy: Customers can read items from their own orders
CREATE POLICY "Customers can read own order items"
    ON order_item
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
              AND o.user_id = jwt_user_id()
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can read all order items
CREATE POLICY "Business Owner can read all order items"
    ON order_item
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all order items
CREATE POLICY "Admin can read all order items"
    ON order_item
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Anonymous users (guests) can insert order items for guest orders
-- This enables guest checkout: guests can add items to orders with reference numbers
CREATE POLICY "Anonymous users can insert order items"
    ON order_item
    FOR INSERT
    TO anon
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
              AND o.reference_number IS NOT NULL
        )
    );

-- Policy: Customers can insert items to their own orders
CREATE POLICY "Customers can insert own order items"
    ON order_item
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
              AND o.user_id = jwt_user_id()
              AND o.status IN ('created', 'submitted') -- Only allow adding items to orders in initial states
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can insert order items (for manual adjustments)
CREATE POLICY "Business Owner can insert order items"
    ON order_item
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert order items
CREATE POLICY "Admin can insert order items"
    ON order_item
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Customers can update items in their own orders (limited to orders in 'created' status)
CREATE POLICY "Customers can update own order items"
    ON order_item
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
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
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
              AND o.user_id = jwt_user_id()
              AND o.status = 'created'
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can update order items
CREATE POLICY "Business Owner can update order items"
    ON order_item
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update order items
CREATE POLICY "Admin can update order items"
    ON order_item
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Customers can delete items from their own orders (only before submission)
CREATE POLICY "Customers can delete own order items"
    ON order_item
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "order" o
            WHERE o.id = order_item.order_id
              AND o.user_id = jwt_user_id()
              AND o.status = 'created' -- Only allow deletion before submission
        )
        AND (
            jwt_has_user_group('Customer')
            OR jwt_has_user_group('Business Owner')
            OR jwt_has_user_group('Admin')
        )
    );

-- Policy: Business Owner can delete order items
CREATE POLICY "Business Owner can delete order items"
    ON order_item
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete order items
CREATE POLICY "Admin can delete order items"
    ON order_item
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


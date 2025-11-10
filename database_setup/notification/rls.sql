-- Row-Level Security Policies for notification
-- Uses Auth0 JWT claims with user_group array
-- Roles: Admin (all access), Business Owner (all access), Customer (read active notifications only)

-- Helper function to check if user is a recent purchaser (for audience filtering)
CREATE OR REPLACE FUNCTION user_is_recent_purchaser(user_id_param TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM "order" o
        WHERE o.user_id = user_id_param
          AND o.status IN ('submitted', 'accepted', 'in_progress', 'ready', 'completed')
          AND o.submitted_at IS NOT NULL
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER TABLE notification ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users (guests) can read public notifications for all customers
CREATE POLICY "Anonymous users can read public notifications"
    ON notification
    FOR SELECT
    TO anon
    USING (
        -- Notification must be active (published and not expired)
        published_at <= NOW()
        AND (expiry_at IS NULL OR expiry_at > NOW())
        AND audience = 'all_customers' -- Only show public notifications to guests
    );

-- Policy: Customers can read active notifications (filtered by audience)
CREATE POLICY "Customers can read active notifications"
    ON notification
    FOR SELECT
    TO authenticated
    USING (
        -- Notification must be active (published and not expired)
        published_at <= NOW()
        AND (expiry_at IS NULL OR expiry_at > NOW())
        AND (
            -- If audience is 'all_customers', show to all authenticated users
            (audience = 'all_customers' AND (
                jwt_has_user_group('Customer')
                OR jwt_has_user_group('Business Owner')
                OR jwt_has_user_group('Admin')
            ))
            -- If audience is 'recent_purchasers', show only to users who have placed orders
            OR (audience = 'recent_purchasers' AND (
                user_is_recent_purchaser(jwt_user_id())
                OR jwt_has_user_group('Business Owner')
                OR jwt_has_user_group('Admin')
            ))
        )
    );

-- Policy: Business Owner can read all notifications
CREATE POLICY "Business Owner can read all notifications"
    ON notification
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can read all notifications
CREATE POLICY "Admin can read all notifications"
    ON notification
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Policy: Business Owner can insert notifications
CREATE POLICY "Business Owner can insert notifications"
    ON notification
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can insert notifications
CREATE POLICY "Admin can insert notifications"
    ON notification
    FOR INSERT
    TO authenticated
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can update notifications
CREATE POLICY "Business Owner can update notifications"
    ON notification
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Policy: Admin can update notifications
CREATE POLICY "Admin can update notifications"
    ON notification
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

-- Policy: Business Owner can delete notifications
CREATE POLICY "Business Owner can delete notifications"
    ON notification
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Policy: Admin can delete notifications
CREATE POLICY "Admin can delete notifications"
    ON notification
    FOR DELETE
    TO authenticated
    USING (jwt_has_user_group('Admin'));


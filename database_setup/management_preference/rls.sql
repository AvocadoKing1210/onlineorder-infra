-- Row-Level Security Policies for management_preference
-- Only Business Owner and Admin can manage preferences (customers have no access)

ALTER TABLE management_preference ENABLE ROW LEVEL SECURITY;

-- Clear role-specific policies and restrict to owner/admin only

-- Business Owner can manage all preferences
CREATE POLICY "Business Owner can manage management preferences"
    ON management_preference
    FOR ALL
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Admin can manage all preferences
CREATE POLICY "Admin can manage management preferences"
    ON management_preference
    FOR ALL
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

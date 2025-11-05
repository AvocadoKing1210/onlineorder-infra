-- Row-Level Security Policies for management_preference
-- Users manage their own preferences; Business Owner/Admin can manage all

ALTER TABLE management_preference ENABLE ROW LEVEL SECURITY;

-- Users can read their own preferences
CREATE POLICY "Users can read own management preferences"
    ON management_preference
    FOR SELECT
    TO authenticated
    USING (user_id = jwt_user_id());

-- Users can insert their own preferences
CREATE POLICY "Users can insert own management preferences"
    ON management_preference
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = jwt_user_id());

-- Users can update their own preferences
CREATE POLICY "Users can update own management preferences"
    ON management_preference
    FOR UPDATE
    TO authenticated
    USING (user_id = jwt_user_id())
    WITH CHECK (user_id = jwt_user_id());

-- Business Owner can read all preferences
CREATE POLICY "Business Owner can read all management preferences"
    ON management_preference
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Business Owner'));

-- Admin can read all preferences
CREATE POLICY "Admin can read all management preferences"
    ON management_preference
    FOR SELECT
    TO authenticated
    USING (jwt_has_user_group('Admin'));

-- Business Owner can update all preferences
CREATE POLICY "Business Owner can update all management preferences"
    ON management_preference
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Business Owner'))
    WITH CHECK (jwt_has_user_group('Business Owner'));

-- Admin can update all preferences
CREATE POLICY "Admin can update all management preferences"
    ON management_preference
    FOR UPDATE
    TO authenticated
    USING (jwt_has_user_group('Admin'))
    WITH CHECK (jwt_has_user_group('Admin'));

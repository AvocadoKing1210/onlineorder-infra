-- Add RLS policy to allow reading basic user profile info for public display
-- This allows displaying user names and avatars in reviews, comments, etc.
-- 
-- SECURITY NOTE: This policy allows reading the entire user_profile row.
-- However, we mitigate this risk by:
-- 1. Only querying specific columns (display_name, avatar_url) in our application code
-- 2. Using a view (public_user_profile) that only exposes safe fields (see create_public_profile_view.sql)
-- 3. Only exposing profiles of users who have approved reviews (not all users)
--
-- For maximum security, use the public_user_profile view instead of querying user_profile directly.

-- Policy: Allow reading basic profile info for users who have approved reviews
-- This is more secure than allowing all profiles, as it only exposes profiles
-- of users who have contributed public content (approved reviews)
CREATE POLICY "Allow reading public profile info for reviewers"
    ON user_profile
    FOR SELECT
    TO authenticated, anon
    USING (
        -- Only allow reading profiles of users who have at least one approved review
        EXISTS (
            SELECT 1 FROM review r
            WHERE r.user_id = user_profile.id
            AND r.status = 'approved'
        )
    );

-- RECOMMENDED: Use the public_user_profile view instead of user_profile table
-- The view only exposes id, display_name, and avatar_url
-- See: create_public_profile_view.sql


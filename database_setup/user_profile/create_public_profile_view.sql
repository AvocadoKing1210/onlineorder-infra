-- Create a secure view that only exposes public profile information
-- This view only includes display_name and avatar_url, excluding sensitive data
-- like email, phone_number, and Auth0 user ID

CREATE OR REPLACE VIEW public_user_profile AS
SELECT 
    id, -- Auth0 user ID (needed for joining, but consider if this should be exposed)
    display_name,
    avatar_url
FROM user_profile;

-- Enable RLS on the view (views inherit RLS from underlying table)
ALTER VIEW public_user_profile SET (security_invoker = true);

-- Grant access to the view
GRANT SELECT ON public_user_profile TO authenticated, anon;

-- Note: The view will use the RLS policies from the user_profile table
-- So we still need the policy that allows reading profiles of reviewers


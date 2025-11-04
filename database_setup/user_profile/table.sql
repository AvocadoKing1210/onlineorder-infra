-- User Profile Table
-- Stores user profile information (display name, avatar, locale preferences)
-- Links to Auth0 user via Auth0 user ID (sub claim from JWT)
-- Records are automatically created via Auth0 "post-user-registration" action

CREATE TABLE IF NOT EXISTS user_profile (
    id TEXT PRIMARY KEY, -- Auth0 user ID (from JWT 'sub' claim)
    
    -- User Information
    email TEXT NOT NULL UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    phone_number TEXT,
    
    -- Preferences
    preferred_locale TEXT NOT NULL DEFAULT 'en',
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for faster lookups by email
CREATE INDEX IF NOT EXISTS idx_user_profile_email ON user_profile(email);

-- Create index for locale queries
CREATE INDEX IF NOT EXISTS idx_user_profile_locale ON user_profile(preferred_locale);

-- Create updated_at trigger (reuse the function from restaurant_settings)
CREATE TRIGGER update_user_profile_updated_at
    BEFORE UPDATE ON user_profile
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


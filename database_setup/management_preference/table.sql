-- Management Preference Table
-- Stores management portal preferences per user (owner/admin/staff)
-- One row per user (identified by Auth0 user ID)

CREATE TABLE IF NOT EXISTS management_preference (
    user_id TEXT PRIMARY KEY, -- Auth0 user ID (from JWT 'sub' claim)

    -- UI Preferences
    theme TEXT NOT NULL DEFAULT 'system' CHECK (theme IN ('light','dark','system')),
    preferred_locale TEXT NOT NULL DEFAULT 'en',
    sidebar_collapsed BOOLEAN NOT NULL DEFAULT false,
    notifications_enabled BOOLEAN NOT NULL DEFAULT true,
    user_guide_completed BOOLEAN NOT NULL DEFAULT false,

    -- Flexible layout/config blob for future expansion
    layout JSONB,

    -- Activity
    last_seen_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_management_preference_locale ON management_preference(preferred_locale);

-- updated_at trigger
CREATE TRIGGER update_management_preference_updated_at
    BEFORE UPDATE ON management_preference
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

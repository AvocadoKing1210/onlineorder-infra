-- Notification Table
-- Stores in-app announcements/notifications from business owner
-- Supports audience filtering (all customers / recent purchasers)
-- Supports expiry dates for time-limited announcements

CREATE TABLE IF NOT EXISTS notification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Notification Content
    title TEXT NOT NULL,
    body TEXT NOT NULL,

    -- Audience Filtering
    -- all_customers: Visible to all authenticated customers
    -- recent_purchasers: Visible only to users who have placed orders
    audience TEXT NOT NULL CHECK (audience IN ('all_customers', 'recent_purchasers')),

    -- Publishing and Expiry
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), -- When notification becomes visible
    expiry_at TIMESTAMPTZ, -- When notification expires (NULL = no expiry)

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_notification_published_at ON notification(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_audience ON notification(audience);
-- Composite index for active notifications query (published and expiry)
CREATE INDEX IF NOT EXISTS idx_notification_published_expiry ON notification(published_at DESC, expiry_at);
-- Index for expiry cleanup queries
CREATE INDEX IF NOT EXISTS idx_notification_expiry ON notification(expiry_at) WHERE expiry_at IS NOT NULL;

-- updated_at trigger
CREATE TRIGGER update_notification_updated_at
    BEFORE UPDATE ON notification
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


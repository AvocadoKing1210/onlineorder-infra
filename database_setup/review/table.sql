-- Review Table
-- Stores customer reviews for menu items
-- Reviews are moderated externally (status: pending/approved/rejected)
-- Only approved reviews are visible to customers

CREATE TABLE IF NOT EXISTS review (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- User Information
    user_id TEXT NOT NULL, -- Auth0 user ID (from JWT 'sub' claim)
    -- Note: No foreign key to user_profile to avoid circular dependency

    -- Menu Item Reference
    menu_item_id UUID NOT NULL REFERENCES menu_item(id) ON DELETE CASCADE,

    -- Review Content
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- 1-5 star rating
    text TEXT, -- Review text (optional, but rating is required)

    -- Moderation Status
    -- pending: Awaiting moderation (external system)
    -- approved: Approved and visible to customers
    -- rejected: Rejected and not visible to customers
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_review_user_id ON review(user_id);
CREATE INDEX IF NOT EXISTS idx_review_menu_item_id ON review(menu_item_id);
CREATE INDEX IF NOT EXISTS idx_review_status ON review(status);
-- Composite index for displaying approved reviews for a menu item
CREATE INDEX IF NOT EXISTS idx_review_menu_item_status_created ON review(menu_item_id, status, created_at DESC) WHERE status = 'approved';
-- Index for user's own reviews (all statuses)
CREATE INDEX IF NOT EXISTS idx_review_user_created ON review(user_id, created_at DESC);

-- Prevent duplicate reviews from same user for same menu item
CREATE UNIQUE INDEX IF NOT EXISTS idx_review_user_menu_item_unique ON review(user_id, menu_item_id);

-- updated_at trigger
CREATE TRIGGER update_review_updated_at
    BEFORE UPDATE ON review
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


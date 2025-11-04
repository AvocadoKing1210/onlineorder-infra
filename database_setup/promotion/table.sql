-- Promotion Table
-- Stores promotions and discounts (BOGO, percentage off, amount off)
-- Promotions can be time-limited and have usage limits

CREATE TABLE IF NOT EXISTS promotion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Promotion Information
    name TEXT NOT NULL,
    description TEXT,

    -- Promotion Type
    -- bogo: Buy One Get One (or buy X get Y)
    -- percent_off: Percentage discount (e.g., 20% off)
    -- amount_off: Fixed amount discount (e.g., $5 off)
    type TEXT NOT NULL CHECK (type IN ('bogo', 'percent_off', 'amount_off')),

    -- Discount Values (only one applies based on type)
    percent_off NUMERIC(5, 2), -- e.g., 20.00 for 20% off (only for percent_off type)
    amount_off_cents INTEGER, -- e.g., 500 for $5.00 off (only for amount_off type)

    -- Active Period
    active_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active_until TIMESTAMPTZ, -- NULL = no end date

    -- Usage Limits
    stackable BOOLEAN NOT NULL DEFAULT false, -- Can this promotion stack with others?
    limit_per_user INTEGER, -- NULL = unlimited per user
    limit_total INTEGER, -- NULL = unlimited total uses

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_promotion_type ON promotion(type);
CREATE INDEX IF NOT EXISTS idx_promotion_active_dates ON promotion(active_from, active_until);
CREATE INDEX IF NOT EXISTS idx_promotion_active ON promotion(active_from, active_until) WHERE active_until IS NULL OR active_until > NOW();

-- Trigger for updated_at
CREATE TRIGGER update_promotion_updated_at
    BEFORE UPDATE ON promotion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


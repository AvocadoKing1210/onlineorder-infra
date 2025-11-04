-- Promotion Category Table (Optional)
-- Links promotions to entire categories instead of specific items
-- Useful for "20% off all desserts" type promotions

CREATE TABLE IF NOT EXISTS promotion_category (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    promotion_id UUID NOT NULL REFERENCES promotion(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES menu_category(id) ON DELETE CASCADE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Prevent duplicate associations
    UNIQUE (promotion_id, category_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_promotion_category_promotion ON promotion_category(promotion_id);
CREATE INDEX IF NOT EXISTS idx_promotion_category_category ON promotion_category(category_id);

-- Trigger for updated_at
CREATE TRIGGER update_promotion_category_updated_at
    BEFORE UPDATE ON promotion_category
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


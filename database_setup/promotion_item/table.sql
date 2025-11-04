-- Promotion Item Table
-- Links promotions to specific menu items with roles
-- Role: 'buy' = item that must be purchased, 'get' = item that is free/discounted, 'target' = item that receives discount

CREATE TABLE IF NOT EXISTS promotion_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    promotion_id UUID NOT NULL REFERENCES promotion(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_item(id) ON DELETE CASCADE,

    -- Role in the promotion
    -- buy: Item that must be purchased (for BOGO: "buy 1 pizza")
    -- get: Item that is free/discounted (for BOGO: "get 1 pizza free")
    -- target: Item that receives discount (for percent_off/amount_off: "20% off wings")
    role TEXT NOT NULL CHECK (role IN ('buy', 'get', 'target')),

    -- Quantities (for BOGO promotions)
    required_quantity INTEGER DEFAULT 1, -- For 'buy' role: how many must be purchased
    get_quantity INTEGER DEFAULT 1, -- For 'get' role: how many are free/discounted

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_promotion_item_promotion ON promotion_item(promotion_id);
CREATE INDEX IF NOT EXISTS idx_promotion_item_menu_item ON promotion_item(menu_item_id);
CREATE INDEX IF NOT EXISTS idx_promotion_item_role ON promotion_item(role);

-- Trigger for updated_at
CREATE TRIGGER update_promotion_item_updated_at
    BEFORE UPDATE ON promotion_item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


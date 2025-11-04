-- Order Item Modifier Table
-- Stores modifier options selected for each order item with price delta snapshots
-- Prices are snapshotted at order submission time for historical accuracy

CREATE TABLE IF NOT EXISTS order_item_modifier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    order_item_id UUID NOT NULL REFERENCES order_item(id) ON DELETE CASCADE,
    modifier_option_id UUID NOT NULL REFERENCES menu_modifier_option(id), -- Keep reference even if option deleted

    -- Modifier Details (snapshotted at order time)
    modifier_group_name TEXT NOT NULL, -- Snapshot of menu_modifier_group.name
    modifier_option_name TEXT NOT NULL, -- Snapshot of menu_modifier_option.name
    price_delta NUMERIC(12, 2) NOT NULL DEFAULT 0, -- Snapshot of menu_modifier_option.price_delta

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_order_item_modifier_order_item_id ON order_item_modifier(order_item_id);
CREATE INDEX IF NOT EXISTS idx_order_item_modifier_option_id ON order_item_modifier(modifier_option_id);

-- updated_at trigger
CREATE TRIGGER update_order_item_modifier_updated_at
    BEFORE UPDATE ON order_item_modifier
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


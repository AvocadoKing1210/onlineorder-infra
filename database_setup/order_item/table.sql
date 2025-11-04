-- Order Item Table
-- Stores individual items within an order with price snapshots
-- Prices are snapshotted at order submission time for historical accuracy

CREATE TABLE IF NOT EXISTS order_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    order_id UUID NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_item(id), -- Keep reference even if item deleted

    -- Item Details (snapshotted at order time)
    item_name TEXT NOT NULL, -- Snapshot of menu_item.name at order time
    item_description TEXT, -- Snapshot of menu_item.description
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0), -- Snapshot of menu_item.price

    -- Quantity and Pricing
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    line_total NUMERIC(12, 2) NOT NULL CHECK (line_total >= 0), -- unit_price * quantity (before modifiers)

    -- Notes
    notes TEXT, -- Customer notes for this specific item

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_order_item_order_id ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_menu_item_id ON order_item(menu_item_id);

-- updated_at trigger
CREATE TRIGGER update_order_item_updated_at
    BEFORE UPDATE ON order_item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


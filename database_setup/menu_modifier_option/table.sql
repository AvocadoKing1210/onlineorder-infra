-- Menu Modifier Option Table
-- Stores individual options within a modifier group
-- Examples: "Small", "Medium", "Large" for Size group; "Pepperoni", "Mushrooms" for Toppings

CREATE TABLE IF NOT EXISTS menu_modifier_option (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    modifier_group_id UUID NOT NULL REFERENCES menu_modifier_group(id) ON DELETE CASCADE,

    -- Option Information
    name TEXT NOT NULL,
    price_delta NUMERIC(12, 2) NOT NULL DEFAULT 0, -- Price adjustment (can be negative for discounts)

    -- Display and ordering
    position INTEGER NOT NULL DEFAULT 0,
    visible BOOLEAN NOT NULL DEFAULT true,
    available BOOLEAN NOT NULL DEFAULT true, -- Separate from visible: can show but mark as unavailable (e.g., "Large - Out of Stock")

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_menu_modifier_option_group ON menu_modifier_option(modifier_group_id);
CREATE INDEX IF NOT EXISTS idx_menu_modifier_option_group_position ON menu_modifier_option(modifier_group_id, position);
CREATE INDEX IF NOT EXISTS idx_menu_modifier_option_available ON menu_modifier_option(available);

-- Unique position within a group
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_modifier_option_group_position_unique ON menu_modifier_option(modifier_group_id, position);

-- Trigger for updated_at
CREATE TRIGGER update_menu_modifier_option_updated_at
    BEFORE UPDATE ON menu_modifier_option
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


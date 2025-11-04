-- Menu Modifier Group Table
-- Stores modifier groups that can be attached to menu items (many-to-many)
-- Examples: "Size", "Toppings", "Extras", "Sauce"
-- Groups can be reused across multiple menu items

CREATE TABLE IF NOT EXISTS menu_modifier_group (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Group Information
    name TEXT NOT NULL,

    -- Selection Rules
    -- min_select: Minimum number of options customer MUST select (0 = optional)
    -- max_select: Maximum number of options customer CAN select
    -- Examples:
    --   Size group: min_select=1, max_select=1 (must pick exactly one)
    --   Toppings: min_select=0, max_select=5 (optional, can pick 0-5)
    --   Required add-ons: min_select=1, max_select=3 (must pick 1-3)
    min_select INTEGER NOT NULL DEFAULT 0 CHECK (min_select >= 0),
    max_select INTEGER NOT NULL DEFAULT 1 CHECK (max_select >= min_select),
    required BOOLEAN NOT NULL DEFAULT false, -- If true, min_select must be >= 1

    -- Display and ordering
    position INTEGER NOT NULL DEFAULT 0,
    visible BOOLEAN NOT NULL DEFAULT true,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_menu_modifier_group_position ON menu_modifier_group(position);
CREATE INDEX IF NOT EXISTS idx_menu_modifier_group_visible ON menu_modifier_group(visible);

-- Trigger for updated_at
CREATE TRIGGER update_menu_modifier_group_updated_at
    BEFORE UPDATE ON menu_modifier_group
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


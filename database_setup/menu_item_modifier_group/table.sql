-- Menu Item Modifier Group Junction Table
-- Many-to-many relationship between menu items and modifier groups
-- Allows modifier groups to be reused across multiple menu items
-- Example: "Size" group can be attached to Pizza, Burger, and Drink items

CREATE TABLE IF NOT EXISTS menu_item_modifier_group (
    -- Relationships
    menu_item_id UUID NOT NULL REFERENCES menu_item(id) ON DELETE CASCADE,
    modifier_group_id UUID NOT NULL REFERENCES menu_modifier_group(id) ON DELETE CASCADE,

    -- Item-specific overrides (optional)
    -- These override the group's default min_select/max_select/required for this specific item
    min_select_override INTEGER, -- NULL = use group's min_select
    max_select_override INTEGER, -- NULL = use group's max_select
    required_override BOOLEAN, -- NULL = use group's required

    -- Display ordering within the item
    position INTEGER NOT NULL DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (menu_item_id, modifier_group_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_menu_item_modifier_group_item ON menu_item_modifier_group(menu_item_id);
CREATE INDEX IF NOT EXISTS idx_menu_item_modifier_group_group ON menu_item_modifier_group(modifier_group_id);
CREATE INDEX IF NOT EXISTS idx_menu_item_modifier_group_position ON menu_item_modifier_group(menu_item_id, position);

-- Unique position within an item
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_item_modifier_group_item_position_unique ON menu_item_modifier_group(menu_item_id, position);

-- Trigger for updated_at
CREATE TRIGGER update_menu_item_modifier_group_updated_at
    BEFORE UPDATE ON menu_item_modifier_group
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


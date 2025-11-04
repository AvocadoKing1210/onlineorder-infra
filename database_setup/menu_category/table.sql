-- Menu Category Table
-- Stores menu categories for organizing menu items
-- Categories can be shown/hidden and ordered by position

CREATE TABLE IF NOT EXISTS menu_category (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Category Information
    name TEXT NOT NULL,
    position INTEGER NOT NULL DEFAULT 0, -- Used for sorting/ordering categories
    
    -- Visibility
    visible BOOLEAN NOT NULL DEFAULT true, -- Whether category is visible to customers
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for faster lookups by position (for ordering)
CREATE INDEX IF NOT EXISTS idx_menu_category_position ON menu_category(position);

-- Create index for visibility queries
CREATE INDEX IF NOT EXISTS idx_menu_category_visible ON menu_category(visible);

-- Create unique constraint on position to prevent duplicates (optional - remove if multiple categories can have same position)
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_category_position_unique ON menu_category(position);

-- Create updated_at trigger (reuse the function from restaurant_settings)
CREATE TRIGGER update_menu_category_updated_at
    BEFORE UPDATE ON menu_category
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


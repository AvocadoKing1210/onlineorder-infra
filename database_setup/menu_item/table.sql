-- Menu Item Table
-- Stores individual items within categories, including pricing and media references

CREATE TABLE IF NOT EXISTS menu_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    category_id UUID NOT NULL REFERENCES menu_category(id) ON DELETE CASCADE,

    -- Item Information
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),

    -- Media references
    image_url TEXT,
    video_ref TEXT, -- e.g., Cloudflare Stream ID

    -- Display and ordering
    position INTEGER NOT NULL DEFAULT 0,
    visible BOOLEAN NOT NULL DEFAULT true,

    -- Tags and availability notes
    dietary_tags TEXT[], -- e.g., ['vegan','gluten_free']
    availability_notes TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_menu_item_category ON menu_item(category_id);
CREATE INDEX IF NOT EXISTS idx_menu_item_category_position ON menu_item(category_id, position);
CREATE INDEX IF NOT EXISTS idx_menu_item_visible ON menu_item(visible);
-- Partial GIN index for faster tag-filter queries on visible items
CREATE INDEX IF NOT EXISTS idx_menu_item_visible_tags_gin ON menu_item USING GIN (dietary_tags) WHERE visible = true;

-- Optional: enforce unique position within a category
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_item_category_position_unique ON menu_item(category_id, position);

-- updated_at trigger
CREATE TRIGGER update_menu_item_updated_at
    BEFORE UPDATE ON menu_item
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();



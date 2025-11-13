-- Add soft delete support to menu_item table
-- This allows items to be "deleted" (hidden from management platform) 
-- while preserving data integrity for historical orders

ALTER TABLE menu_item 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Create index for filtering out deleted items
CREATE INDEX IF NOT EXISTS idx_menu_item_deleted_at ON menu_item(deleted_at) WHERE deleted_at IS NULL;

-- Update the unique position constraint to exclude deleted items
-- This allows deleted items to have the same position as active items
DROP INDEX IF EXISTS idx_menu_item_category_position_unique;
CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_item_category_position_unique 
ON menu_item(category_id, position) 
WHERE deleted_at IS NULL;


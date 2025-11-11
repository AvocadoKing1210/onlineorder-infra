-- Add Customer Information Fields to Order Table
-- This migration adds fields to store customer contact information for guest checkout
-- and delivery addresses for delivery orders

-- Customer Contact Information (for guest checkout and notifications)
ALTER TABLE "order" 
ADD COLUMN IF NOT EXISTS customer_name TEXT,
ADD COLUMN IF NOT EXISTS customer_email TEXT,
ADD COLUMN IF NOT EXISTS customer_phone TEXT;

-- Delivery Address (stored as JSONB for flexibility)
-- Structure: {
--   "street": "123 Main St",
--   "city": "Ottawa",
--   "province": "ON",
--   "postal_code": "K1A 0A6",
--   "country": "Canada",
--   "unit": "Apt 4B" (optional),
--   "instructions": "Ring doorbell" (optional)
-- }
ALTER TABLE "order"
ADD COLUMN IF NOT EXISTS delivery_address JSONB;

-- Indexes for customer information lookups
CREATE INDEX IF NOT EXISTS idx_order_customer_email ON "order"(customer_email) WHERE customer_email IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_order_customer_phone ON "order"(customer_phone) WHERE customer_phone IS NOT NULL;

-- Index for delivery orders (filtering by mode and address)
CREATE INDEX IF NOT EXISTS idx_order_delivery_address ON "order"(mode, delivery_address) WHERE mode = 'delivery' AND delivery_address IS NOT NULL;


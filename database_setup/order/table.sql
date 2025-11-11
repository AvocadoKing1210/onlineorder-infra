-- Order Table
-- Stores customer orders with status tracking, totals, and mode information
-- Designed to support Supabase Realtime subscriptions for order status updates

CREATE TABLE IF NOT EXISTS "order" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- User Information
    user_id TEXT NOT NULL, -- Auth0 user ID (from JWT 'sub' claim)
    -- Note: No foreign key to user_profile to avoid circular dependency during user creation

    -- Order Mode
    -- dine_in: QR code scanned at table
    -- takeout: Customer picks up
    -- delivery: Delivery to customer (optional)
    -- view_only: Browsing only, no orders
    mode TEXT NOT NULL CHECK (mode IN ('dine_in', 'takeout', 'delivery', 'view_only')),

    -- Order Status
    -- created: Order created in cart (not yet submitted)
    -- submitted: Order submitted and awaiting acceptance
    -- accepted: Order accepted by restaurant
    -- in_progress: Order being prepared
    -- ready: Order ready for pickup/delivery
    -- completed: Order fulfilled
    -- cancelled_by_user: User cancelled within window
    -- cancelled_by_store: Restaurant cancelled
    status TEXT NOT NULL DEFAULT 'created' CHECK (status IN (
        'created',
        'submitted',
        'accepted',
        'in_progress',
        'ready',
        'completed',
        'cancelled_by_user',
        'cancelled_by_store'
    )),

    -- Financial Totals (all in NUMERIC for precision)
    -- These are calculated at order submission time and stored as snapshots
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    tax_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    fees_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (fees_amount >= 0),
    tip_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (tip_amount >= 0),
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),

    -- Dine-in Specific
    dining_table_id UUID, -- References dining_table(id) - will be created later
    -- Note: We'll add the foreign key constraint after dining_table table exists

    -- Order Timing
    -- estimated_preparation_minutes: Time to prepare the order (for all modes)
    -- estimated_arrival_at: When the order will arrive at customer location (for delivery mode only)
    estimated_preparation_minutes INTEGER CHECK (estimated_preparation_minutes >= 0), -- Estimated preparation time in minutes (set by restaurant)
    estimated_arrival_at TIMESTAMPTZ, -- Estimated arrival time at customer location (for delivery mode)
    submitted_at TIMESTAMPTZ, -- When order was submitted (NULL if still in 'created' status)
    accepted_at TIMESTAMPTZ, -- When order was accepted
    completed_at TIMESTAMPTZ, -- When order was completed

    -- Special Instructions
    special_instructions TEXT,

    -- Idempotency (prevent duplicate submissions)
    idempotency_key TEXT UNIQUE, -- Client-generated unique key for submission

    -- Reference Number (for guest checkout and Realtime access)
    reference_number TEXT UNIQUE, -- Server-generated reference number for order tracking
    -- Used for: guest order lookup, Realtime subscriptions, customer-facing order ID

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_order_user_id ON "order"(user_id);
CREATE INDEX IF NOT EXISTS idx_order_status ON "order"(status);
CREATE INDEX IF NOT EXISTS idx_order_mode ON "order"(mode);
CREATE INDEX IF NOT EXISTS idx_order_created_at ON "order"(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_submitted_at ON "order"(submitted_at DESC) WHERE submitted_at IS NOT NULL;
-- Composite index for owner portal queries (most common: filter by status, order by submitted_at)
CREATE INDEX IF NOT EXISTS idx_order_status_submitted ON "order"(status, submitted_at DESC) WHERE submitted_at IS NOT NULL;
-- Index for dine-in orders
CREATE INDEX IF NOT EXISTS idx_order_dining_table ON "order"(dining_table_id) WHERE dining_table_id IS NOT NULL;
-- Index for idempotency key lookups
CREATE INDEX IF NOT EXISTS idx_order_idempotency_key ON "order"(idempotency_key) WHERE idempotency_key IS NOT NULL;
-- Index for reference number lookups (guest order access)
CREATE INDEX IF NOT EXISTS idx_order_reference_number ON "order"(reference_number) WHERE reference_number IS NOT NULL;

-- updated_at trigger (reuse function from restaurant_settings)
CREATE TRIGGER update_order_updated_at
    BEFORE UPDATE ON "order"
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


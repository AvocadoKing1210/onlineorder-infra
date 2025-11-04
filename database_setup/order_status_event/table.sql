-- Order Status Event Table
-- Stores audit trail of all order status changes
-- Tracks who made the change (system/staff/user) and when
-- Used for order history and debugging

CREATE TABLE IF NOT EXISTS order_status_event (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    order_id UUID NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,

    -- Event Information
    status TEXT NOT NULL CHECK (status IN (
        'created',
        'submitted',
        'accepted',
        'in_progress',
        'ready',
        'completed',
        'cancelled_by_user',
        'cancelled_by_store'
    )),
    
    -- Actor Information
    -- system: Automated transition (e.g., auto-cancellation after timeout)
    -- staff: Business Owner or Admin action
    -- user: Customer action
    actor_type TEXT NOT NULL CHECK (actor_type IN ('system', 'staff', 'user')),
    actor_id TEXT, -- User ID (from JWT 'sub' claim) if actor_type is 'staff' or 'user', NULL for 'system'

    -- Optional Message
    message TEXT, -- Human-readable message explaining the change

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_order_status_event_order_id ON order_status_event(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_event_status ON order_status_event(status);
CREATE INDEX IF NOT EXISTS idx_order_status_event_created_at ON order_status_event(created_at DESC);
-- Composite index for order history queries
CREATE INDEX IF NOT EXISTS idx_order_status_event_order_created ON order_status_event(order_id, created_at DESC);

-- Note: No updated_at trigger - these are immutable audit records


-- Restaurant Settings Table
-- Stores core business configuration for the restaurant
-- Note: Each Supabase project is scoped to one restaurant, so no restaurant_id needed

CREATE TABLE IF NOT EXISTS restaurant_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Business Information
    business_name TEXT NOT NULL,
    contact_email TEXT,
    contact_phone TEXT,
    address TEXT,
    
    -- Active Modes (array of enabled modes: dine_in, takeout, delivery, view_only)
    active_modes TEXT[] NOT NULL DEFAULT ARRAY['takeout']::TEXT[],
    
    -- Reviews Configuration
    reviews_enabled BOOLEAN NOT NULL DEFAULT false,
    
    -- Menu Format
    menu_format TEXT NOT NULL DEFAULT 'static' CHECK (menu_format IN ('static', 'video', 'both')),
    
    -- Cancellation Policy
    cancellation_allowed BOOLEAN NOT NULL DEFAULT true,
    cancellation_window_minutes INTEGER DEFAULT 15, -- minutes after order submission
    
    -- Operating Hours
    -- JSONB structure: {"monday": {"open": "09:00", "close": "22:00"}, "tuesday": {...}, ...}
    -- Or simpler: single opening_time and closing_time for same hours every day
    opening_hours JSONB, -- Flexible: per-day hours or null if same hours daily
    opening_time TIME, -- Default opening time (used if opening_hours is null)
    closing_time TIME, -- Default closing time (used if opening_hours is null)
    
    -- Localization
    locale TEXT NOT NULL DEFAULT 'en',
    currency TEXT NOT NULL DEFAULT 'CAD',
    timezone TEXT NOT NULL DEFAULT 'America/Toronto', -- Eastern Time (Ottawa/Toronto)
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for faster lookups (though typically only one row exists)
CREATE INDEX IF NOT EXISTS idx_restaurant_settings_id ON restaurant_settings(id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_restaurant_settings_updated_at
    BEFORE UPDATE ON restaurant_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


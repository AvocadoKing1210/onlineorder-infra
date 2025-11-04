-- Order Status Transition Validation Trigger
-- Ensures only valid status transitions are allowed based on user role
-- Customers can only submit orders (created → submitted), but cannot cancel submitted orders
-- Only Business Owner/Admin can cancel submitted orders

CREATE OR REPLACE FUNCTION validate_order_status_transition()
RETURNS TRIGGER AS $$
DECLARE
    user_groups TEXT[];
    is_customer BOOLEAN;
    is_business_owner BOOLEAN;
    is_admin BOOLEAN;
BEGIN
    -- Extract user_group from JWT
    SELECT ARRAY(
        SELECT jsonb_array_elements_text(auth.jwt() -> 'user_group')
    ) INTO user_groups;
    
    is_customer := 'Customer' = ANY(user_groups);
    is_business_owner := 'Business Owner' = ANY(user_groups);
    is_admin := 'Admin' = ANY(user_groups);
    
    -- If status hasn't changed, allow the update (for other fields)
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;
    
    -- Business Owner and Admin can make any status transition
    IF is_business_owner OR is_admin THEN
        RETURN NEW;
    END IF;
    
    -- Customer status transition rules
    IF is_customer THEN
        -- Customers can only submit orders (created → submitted)
        IF OLD.status = 'created' AND NEW.status = 'submitted' THEN
            RETURN NEW;
        END IF;
        
        -- Customers CANNOT cancel submitted orders
        -- They can only delete/modify orders that are still in 'created' status
        -- (which is handled by RLS policies on order_item deletion)
        
        -- Reject any other status change by customer
        RAISE EXCEPTION 'Customer can only submit orders (created → submitted). Status change from % to % is not allowed.', OLD.status, NEW.status;
    END IF;
    
    -- If we get here, user doesn't have proper role
    RAISE EXCEPTION 'Unauthorized: User does not have permission to change order status';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER validate_order_status_transition_trigger
    BEFORE UPDATE ON "order"
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION validate_order_status_transition();


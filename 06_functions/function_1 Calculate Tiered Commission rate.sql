-- ============================================
-- Function: GET_TIERED_COMMISSION_RATE
-- Purpose: Determine commission rate based on sales tier
-- Parameters: p_sales_amount IN - Total sales amount
-- Returns: Commission rate percentage
-- ============================================
CREATE OR REPLACE FUNCTION get_tiered_commission_rate(
    p_sales_amount IN NUMBER
) RETURN NUMBER
IS
    v_commission_rate NUMBER;
BEGIN
    -- Tier-based commission structure
    IF p_sales_amount <= 50000 THEN
        v_commission_rate := 5.0; -- Tier 1
    ELSIF p_sales_amount <= 150000 THEN
        v_commission_rate := 7.5; -- Tier 2
    ELSIF p_sales_amount <= 500000 THEN
        v_commission_rate := 10.0; -- Tier 3
    ELSIF p_sales_amount <= 1000000 THEN
        v_commission_rate := 12.5; -- Tier 4
    ELSE
        v_commission_rate := 15.0; -- Executive tier
    END IF;
    
    RETURN v_commission_rate;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0; -- Default to 0% on error
END get_tiered_commission_rate;
/
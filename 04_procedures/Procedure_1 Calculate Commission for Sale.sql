-- ============================================
-- Procedure: CALCULATE_SALE_COMMISSION
-- Purpose: Calculate commission for a specific sale
-- Parameters: 
--   p_sale_id IN - Sale ID to calculate commission for
--   p_commission_amount OUT - Calculated commission amount
--   p_status OUT - Calculation status
-- ============================================
CREATE OR REPLACE PROCEDURE calculate_sale_commission(
    p_sale_id IN NUMBER,
    p_commission_amount OUT NUMBER,
    p_status OUT VARCHAR2
) 
IS
    v_sale_amount NUMBER;
    v_rep_id NUMBER;
    v_commission_rate NUMBER;
    v_product_commission NUMBER;
    v_tier_commission NUMBER;
    v_total_commission NUMBER;
    v_rule_applied VARCHAR2(100);
    
    -- Exception declarations
    sale_not_found EXCEPTION;
    commission_calculated EXCEPTION;
    
BEGIN
    -- Initialize outputs
    p_commission_amount := 0;
    p_status := 'FAILED';
    
    -- Check if sale exists and commission not already calculated
    BEGIN
        SELECT s.unit_price * s.quantity, s.rep_id, s.commission_calculated
        INTO v_sale_amount, v_rep_id, v_rule_applied
        FROM sale s
        WHERE s.sale_id = p_sale_id;
        
        IF v_rule_applied = 'Y' THEN
            RAISE commission_calculated;
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE sale_not_found;
    END;
    
    -- Get sales rep's base commission rate
    SELECT commission_rate INTO v_commission_rate
    FROM sales_rep
    WHERE rep_id = v_rep_id;
    
    -- Calculate base commission
    v_tier_commission := v_sale_amount * (v_commission_rate / 100);
    
    -- Get product-specific commission rate
    BEGIN
        SELECT p.commission_percentage INTO v_product_commission
        FROM sale s
        JOIN product p ON s.product_id = p.product_id
        WHERE s.sale_id = p_sale_id;
        
        v_tier_commission := v_tier_commission + (v_sale_amount * (v_product_commission / 100));
        v_rule_applied := 'TIERED_WITH_PRODUCT_BONUS';
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_rule_applied := 'TIERED_ONLY';
    END;
    
    -- Apply bonus based on sale amount
    IF v_sale_amount > 100000 THEN
        v_tier_commission := v_tier_commission + 5000; -- Large sale bonus
        v_rule_applied := v_rule_applied || '_WITH_BONUS';
    ELSIF v_sale_amount > 50000 THEN
        v_tier_commission := v_tier_commission + 1000; -- Medium sale bonus
        v_rule_applied := v_rule_applied || '_WITH_BONUS';
    END IF;
    
    -- Ensure commission is not negative
    v_total_commission := GREATEST(v_tier_commission, 0);
    
    -- Insert commission calculation
    INSERT INTO commission_calculation (
        calc_id, sale_id, rep_id, base_amount, 
        commission_rate, commission_amount, rule_applied,
        calculation_method, status
    ) VALUES (
        seq_commission_calc.NEXTVAL, p_sale_id, v_rep_id,
        v_sale_amount, v_commission_rate, v_total_commission,
        v_rule_applied, 'PROCEDURE_CALCULATION', 'CALCULATED'
    );
    
    -- Update sale record
    UPDATE sale
    SET commission_calculated = 'Y'
    WHERE sale_id = p_sale_id;
    
    -- Set output parameters
    p_commission_amount := v_total_commission;
    p_status := 'SUCCESS';
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Commission calculated successfully for Sale ID: ' || p_sale_id);
    DBMS_OUTPUT.PUT_LINE('Amount: $' || ROUND(v_total_commission, 2));
    
EXCEPTION
    WHEN sale_not_found THEN
        p_status := 'ERROR: Sale not found';
        DBMS_OUTPUT.PUT_LINE('Error: Sale ID ' || p_sale_id || ' not found');
        ROLLBACK;
        
    WHEN commission_calculated THEN
        p_status := 'ERROR: Commission already calculated';
        DBMS_OUTPUT.PUT_LINE('Error: Commission already calculated for Sale ID ' || p_sale_id);
        ROLLBACK;
        
    WHEN OTHERS THEN
        p_status := 'ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        ROLLBACK;
        
END calculate_sale_commission;
/
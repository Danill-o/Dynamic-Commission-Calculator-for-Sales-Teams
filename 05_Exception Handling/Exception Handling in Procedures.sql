-- ============================================
-- Enhanced Exception Handling Example
-- ============================================
CREATE OR REPLACE PROCEDURE safe_commission_calculation(
    p_sale_id IN NUMBER
)
IS
    -- Predefined Oracle exceptions
    no_data_found_exception EXCEPTION;
    too_many_rows_exception EXCEPTION;
    
    -- Custom application exceptions
    invalid_sale_status EXCEPTION;
    commission_already_calculated EXCEPTION;
    
    -- Exception variables
    v_error_code NUMBER;
    v_error_message VARCHAR2(4000);
    v_sale_amount NUMBER;
    v_rep_id NUMBER;
    v_sale_status VARCHAR2(20);
    v_calculated_flag CHAR(1);
    
    -- Error logging procedure
    PROCEDURE log_error(
        p_procedure_name IN VARCHAR2,
        p_error_code IN NUMBER,
        p_error_message IN VARCHAR2,
        p_sale_id IN NUMBER
    ) IS
    BEGIN
        INSERT INTO audit_log (
            log_id, table_name, operation_type,
            record_id, old_value, new_value,
            user_name, status, error_message
        ) VALUES (
            seq_audit_log.NEXTVAL, 'SAFE_CALCULATION', 'ERROR',
            p_sale_id,
            'Procedure: ' || p_procedure_name,
            'Error Code: ' || p_error_code,
            USER, 'FAILED', p_error_message
        );
        COMMIT;
    END log_error;
    
BEGIN
    -- Step 1: Validate sale exists and get data
    BEGIN
        SELECT unit_price * quantity, rep_id, sale_status, commission_calculated
        INTO v_sale_amount, v_rep_id, v_sale_status, v_calculated_flag
        FROM sale
        WHERE sale_id = p_sale_id;
        
        IF v_sale_status != 'COMPLETED' THEN
            RAISE invalid_sale_status;
        END IF;
        
        IF v_calculated_flag = 'Y' THEN
            RAISE commission_already_calculated;
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE no_data_found_exception;
        WHEN TOO_MANY_ROWS THEN
            RAISE too_many_rows_exception;
    END;
    
    -- Step 2: Calculate commission
    DECLARE
        v_commission_rate NUMBER;
        v_commission_amount NUMBER;
    BEGIN
        SELECT commission_rate INTO v_commission_rate
        FROM sales_rep
        WHERE rep_id = v_rep_id;
        
        v_commission_amount := v_sale_amount * (v_commission_rate / 100);
        
        -- Insert commission calculation
        INSERT INTO commission_calculation (
            calc_id, sale_id, rep_id, base_amount,
            commission_rate, commission_amount, status
        ) VALUES (
            seq_commission_calc.NEXTVAL, p_sale_id, v_rep_id,
            v_sale_amount, v_commission_rate, v_commission_amount,
            'CALCULATED'
        );
        
        -- Update sale record
        UPDATE sale
        SET commission_calculated = 'Y'
        WHERE sale_id = p_sale_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Commission calculated successfully');
        DBMS_OUTPUT.PUT_LINE('Sale ID: ' || p_sale_id);
        DBMS_OUTPUT.PUT_LINE('Amount: $' || ROUND(v_commission_amount, 2));
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_code := -20001;
            v_error_message := 'Sales rep not found: ' || v_rep_id;
            RAISE;
    END;
    
EXCEPTION
    WHEN no_data_found_exception THEN
        v_error_code := -20002;
        v_error_message := 'Sale not found with ID: ' || p_sale_id;
        log_error('safe_commission_calculation', v_error_code, v_error_message, p_sale_id);
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        
    WHEN too_many_rows_exception THEN
        v_error_code := -20003;
        v_error_message := 'Multiple sales found with ID: ' || p_sale_id;
        log_error('safe_commission_calculation', v_error_code, v_error_message, p_sale_id);
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        
    WHEN invalid_sale_status THEN
        v_error_code := -20004;
        v_error_message := 'Sale status must be COMPLETED. Current: ' || v_sale_status;
        log_error('safe_commission_calculation', v_error_code, v_error_message, p_sale_id);
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        
    WHEN commission_already_calculated THEN
        v_error_code := -20005;
        v_error_message := 'Commission already calculated for sale: ' || p_sale_id;
        log_error('safe_commission_calculation', v_error_code, v_error_message, p_sale_id);
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_message := SQLERRM;
        log_error('safe_commission_calculation', v_error_code, v_error_message, p_sale_id);
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || v_error_message);
        DBMS_OUTPUT.PUT_LINE('Error code: ' || v_error_code);
        
END safe_commission_calculation;
/
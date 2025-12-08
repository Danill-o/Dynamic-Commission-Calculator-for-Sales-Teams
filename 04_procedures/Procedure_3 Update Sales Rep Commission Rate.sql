-- ============================================
-- Procedure: UPDATE_REP_COMMISSION_RATE
-- Purpose: Update commission rate for sales rep with validation
-- Parameters:
--   p_rep_id IN - Sales Rep ID
--   p_new_rate IN - New commission rate
--   p_reason IN - Reason for change
--   p_success OUT - Success flag (Y/N)
--   p_message OUT - Status message
-- ============================================
CREATE OR REPLACE PROCEDURE update_rep_commission_rate(
    p_rep_id IN NUMBER,
    p_new_rate IN NUMBER,
    p_reason IN VARCHAR2 DEFAULT 'ADJUSTMENT',
    p_success OUT CHAR,
    p_message OUT VARCHAR2
)
IS
    v_old_rate NUMBER;
    v_rep_exists NUMBER;
    v_avg_rate NUMBER;
    v_max_rate NUMBER := 20; -- Company policy max rate
    
    -- Custom exceptions
    rep_not_found EXCEPTION;
    invalid_rate EXCEPTION;
    rate_too_high EXCEPTION;
    
BEGIN
    -- Initialize outputs
    p_success := 'N';
    p_message := 'FAILED';
    
    -- Check if rep exists
    SELECT COUNT(*) INTO v_rep_exists
    FROM sales_rep
    WHERE rep_id = p_rep_id;
    
    IF v_rep_exists = 0 THEN
        RAISE rep_not_found;
    END IF;
    
    -- Validate new rate
    IF p_new_rate < 0 OR p_new_rate > 100 THEN
        RAISE invalid_rate;
    END IF;
    
    -- Check company policy
    IF p_new_rate > v_max_rate THEN
        RAISE rate_too_high;
    END IF;
    
    -- Get current rate
    SELECT commission_rate INTO v_old_rate
    FROM sales_rep
    WHERE rep_id = p_rep_id;
    
    -- Get average rate for comparison
    SELECT AVG(commission_rate) INTO v_avg_rate
    FROM sales_rep
    WHERE status = 'ACTIVE';
    
    -- Update commission rate
    UPDATE sales_rep
    SET commission_rate = p_new_rate,
        modified_date = SYSDATE
    WHERE rep_id = p_rep_id;
    
    -- Log the change (simulate audit log)
    INSERT INTO audit_log (
        log_id, table_name, operation_type,
        record_id, old_value, new_value,
        user_name, status
    ) VALUES (
        seq_audit_log.NEXTVAL, 'SALES_REP', 'UPDATE',
        p_rep_id, 'Rate: ' || v_old_rate || '%',
        'Rate: ' || p_new_rate || '% - Reason: ' || p_reason,
        USER, 'SUCCESS'
    );
    
    -- Set output parameters
    p_success := 'Y';
    p_message := 'Commission rate updated from ' || v_old_rate || 
                '% to ' || p_new_rate || '%';
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Sales Rep ' || p_rep_id || ':');
    DBMS_OUTPUT.PUT_LINE('  Old rate: ' || v_old_rate || '%');
    DBMS_OUTPUT.PUT_LINE('  New rate: ' || p_new_rate || '%');
    DBMS_OUTPUT.PUT_LINE('  Average team rate: ' || ROUND(v_avg_rate, 2) || '%');
    DBMS_OUTPUT.PUT_LINE('  Change reason: ' || p_reason);
    
EXCEPTION
    WHEN rep_not_found THEN
        p_message := 'ERROR: Sales Rep ID ' || p_rep_id || ' not found';
        DBMS_OUTPUT.PUT_LINE(p_message);
        ROLLBACK;
        
    WHEN invalid_rate THEN
        p_message := 'ERROR: Invalid commission rate. Must be between 0 and 100';
        DBMS_OUTPUT.PUT_LINE(p_message);
        ROLLBACK;
        
    WHEN rate_too_high THEN
        p_message := 'ERROR: Rate exceeds company maximum of ' || v_max_rate || '%';
        DBMS_OUTPUT.PUT_LINE(p_message);
        ROLLBACK;
        
    WHEN OTHERS THEN
        p_message := 'ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE(p_message);
        ROLLBACK;
        
END update_rep_commission_rate;
/
-- ============================================
-- Trigger: TRG_SALE_BEFORE_UPDATE
-- Purpose: Enforce DML restrictions on SALE table UPDATE operations
-- Trigger Type: BEFORE UPDATE (Statement Level)
-- ============================================
CREATE OR REPLACE TRIGGER trg_sale_before_update
BEFORE UPDATE ON sale
DECLARE
    v_employee_id VARCHAR2(100) := USER;
    v_operation_type VARCHAR2(10) := 'UPDATE';
    v_current_date DATE := SYSDATE;
    v_is_allowed BOOLEAN;
BEGIN
    -- Check if employee can perform DML
    v_is_allowed := can_employee_perform_dml(
        p_employee_id => v_employee_id,
        p_operation_type => v_operation_type,
        p_check_date => v_current_date
    );
    
    -- If not allowed, raise application error
    IF NOT v_is_allowed THEN
        RAISE_APPLICATION_ERROR(
            -20002, 
            'CRITICAL RULE VIOLATION: ' || 
            'UPDATE operations on SALE table are not allowed on ' ||
            CASE 
                WHEN is_weekday(v_current_date) THEN 'weekdays (Monday-Friday)'
                WHEN is_holiday(v_current_date) THEN 'public holidays'
                ELSE 'this day'
            END ||
            '. Operation rejected.'
        );
    END IF;
    
    -- Log successful check
    log_audit_event(
        'SALE', 'BEFORE_UPDATE', 'STATEMENT',
        NULL,
        TO_CLOB('Employee: ' || v_employee_id || 
                ', Date: ' || TO_CHAR(v_current_date, 'YYYY-MM-DD') ||
                ', Time: ' || TO_CHAR(v_current_date, 'HH24:MI:SS')),
        'SUCCESS',
        NULL
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log trigger error
        log_audit_event(
            'SALE', 'TRIGGER_ERROR', 'BEFORE_UPDATE',
            NULL, NULL, 'ERROR',
            'Trigger error: ' || SQLERRM
        );
        RAISE; -- Re-raise the exception
END trg_sale_before_update;
/
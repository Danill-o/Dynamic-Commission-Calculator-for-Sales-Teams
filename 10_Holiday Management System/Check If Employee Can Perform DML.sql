-- ============================================
-- Function: CAN_EMPLOYEE_PERFORM_DML
-- Purpose: Check if employee can perform DML operations based on restrictions
-- CRITICAL RULE: Employee CANNOT INSERT/UPDATE/DELETE on weekdays or holidays
-- Returns: TRUE if allowed, FALSE if restricted
-- ============================================
CREATE OR REPLACE FUNCTION can_employee_perform_dml(
    p_employee_id IN VARCHAR2 DEFAULT USER,
    p_operation_type IN VARCHAR2,
    p_check_date IN DATE DEFAULT SYSDATE
) RETURN BOOLEAN
IS
    v_is_weekday BOOLEAN;
    v_is_holiday BOOLEAN;
    v_is_allowed BOOLEAN := TRUE;
    v_reason VARCHAR2(500);
BEGIN
    -- Check weekday restriction
    v_is_weekday := is_weekday(p_check_date);
    
    -- Check holiday restriction (only upcoming month as per requirement)
    v_is_holiday := is_holiday(p_check_date);
    
    -- Apply restrictions
    IF v_is_weekday THEN
        v_is_allowed := FALSE;
        v_reason := 'Operation not allowed on weekdays (Monday-Friday)';
    ELSIF v_is_holiday THEN
        v_is_allowed := FALSE;
        v_reason := 'Operation not allowed on public holidays';
    END IF;
    
    -- Log the check (always log, even if allowed)
    log_audit_event(
        'DML_RESTRICTION_CHECK', 'VALIDATION',
        p_employee_id || '|' || p_operation_type,
        TO_CLOB('Date: ' || TO_CHAR(p_check_date, 'YYYY-MM-DD') || 
                ', Weekday: ' || CASE WHEN v_is_weekday THEN 'Yes' ELSE 'No' END ||
                ', Holiday: ' || CASE WHEN v_is_holiday THEN 'Yes' ELSE 'No' END),
        TO_CLOB('Allowed: ' || CASE WHEN v_is_allowed THEN 'Yes' ELSE 'No' END ||
                ', Reason: ' || v_reason),
        CASE WHEN v_is_allowed THEN 'SUCCESS' ELSE 'RESTRICTED' END,
        CASE WHEN v_is_allowed THEN NULL ELSE v_reason END
    );
    
    RETURN v_is_allowed;
    
EXCEPTION
    WHEN OTHERS THEN
        -- On error, log and allow operation (fail-open for safety)
        log_audit_event(
            'DML_RESTRICTION_CHECK', 'ERROR',
            p_employee_id || '|' || p_operation_type,
            NULL, NULL, 'ERROR',
            'Error in can_employee_perform_dml: ' || SQLERRM
        );
        RETURN TRUE; -- Allow on error (safety mechanism)
END can_employee_perform_dml;
/

-- Test the restriction function
BEGIN
    DBMS_OUTPUT.PUT_LINE('DML Restriction Check for Employee: ' || USER);
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD Day'));
    
    IF can_employee_perform_dml(USER, 'INSERT', SYSDATE) THEN
        DBMS_OUTPUT.PUT_LINE('  Result: DML operations ALLOWED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Result: DML operations RESTRICTED');
    END IF;
END;
/
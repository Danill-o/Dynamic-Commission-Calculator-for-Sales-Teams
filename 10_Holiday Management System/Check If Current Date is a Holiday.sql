-- ============================================
-- Function: IS_HOLIDAY
-- Purpose: Check if current date is a public holiday
-- Parameters: 
--   p_check_date - Date to check (default SYSDATE)
--   p_country - Country code (default 'USA')
-- Returns: TRUE if holiday, FALSE if not
-- ============================================
CREATE OR REPLACE FUNCTION is_holiday(
    p_check_date IN DATE DEFAULT SYSDATE,
    p_country IN VARCHAR2 DEFAULT 'USA'
) RETURN BOOLEAN
IS
    v_holiday_count NUMBER;
    v_check_month_day VARCHAR2(5);
    v_check_year NUMBER;
BEGIN
    -- First, check for exact date match
    SELECT COUNT(*)
    INTO v_holiday_count
    FROM holiday
    WHERE holiday_date = TRUNC(p_check_date)
      AND country = p_country;
    
    IF v_holiday_count > 0 THEN
        RETURN TRUE;
    END IF;
    
    -- Check for recurring holidays (same month/day, different year)
    v_check_month_day := TO_CHAR(p_check_date, 'MM-DD');
    v_check_year := TO_NUMBER(TO_CHAR(p_check_date, 'YYYY'));
    
    SELECT COUNT(*)
    INTO v_holiday_count
    FROM holiday
    WHERE TO_CHAR(holiday_date, 'MM-DD') = v_check_month_day
      AND is_recurring = 'Y'
      AND country = p_country
      AND holiday_date < p_check_date; -- Only consider past holidays for recurrence
    
    RETURN v_holiday_count > 0;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but return FALSE (allow operation on error)
        log_audit_event(
            'HOLIDAY_CHECK', 'FUNCTION',
            TO_CHAR(p_check_date, 'YYYYMMDD'),
            NULL, NULL, 'ERROR',
            'Error in is_holiday: ' || SQLERRM
        );
        RETURN FALSE;
END is_holiday;
/

-- Test function
BEGIN
    DBMS_OUTPUT.PUT_LINE('Is today (' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ') a holiday?');
    IF is_holiday() THEN
        DBMS_OUTPUT.PUT_LINE('  Yes - Holiday');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  No - Not a holiday');
    END IF;
END;
/
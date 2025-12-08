-- ============================================
-- Function: IS_WEEKDAY
-- Purpose: Check if current date is a weekday (Monday-Friday)
-- Returns: TRUE if weekday, FALSE if weekend
-- ============================================
CREATE OR REPLACE FUNCTION is_weekday(
    p_check_date IN DATE DEFAULT SYSDATE
) RETURN BOOLEAN
IS
    v_day_of_week NUMBER;
BEGIN
    -- Get day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
    v_day_of_week := TO_CHAR(p_check_date, 'D');
    
    -- Return TRUE for Monday-Friday (2-6)
    RETURN v_day_of_week BETWEEN 2 AND 6;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Default to TRUE on error (restrictive)
        RETURN TRUE;
END is_weekday;
/

-- Test function
BEGIN
    DBMS_OUTPUT.PUT_LINE('Is today (' || TO_CHAR(SYSDATE, 'Day') || ') a weekday?');
    IF is_weekday() THEN
        DBMS_OUTPUT.PUT_LINE('  Yes - Weekday');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  No - Weekend');
    END IF;
END;
/
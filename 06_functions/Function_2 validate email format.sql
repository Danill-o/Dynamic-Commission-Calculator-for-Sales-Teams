-- ============================================
-- Function: VALIDATE_EMAIL
-- Purpose: Validate email format
-- Parameters: p_email IN - Email address to validate
-- Returns: 'VALID' or error message
-- ============================================
CREATE OR REPLACE FUNCTION validate_email(
    p_email IN VARCHAR2
) RETURN VARCHAR2
IS
    v_email VARCHAR2(100);
    v_pattern VARCHAR2(100) := '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
BEGIN
    -- Check for NULL
    IF p_email IS NULL THEN
        RETURN 'ERROR: Email cannot be NULL';
    END IF;
    
    -- Check length
    IF LENGTH(p_email) > 100 THEN
        RETURN 'ERROR: Email exceeds maximum length (100)';
    END IF;
    
    -- Basic format check using LIKE
    IF p_email NOT LIKE '%@%.%' THEN
        RETURN 'ERROR: Invalid email format (missing @ or .)';
    END IF;
    
    -- Check for spaces
    IF INSTR(p_email, ' ') > 0 THEN
        RETURN 'ERROR: Email cannot contain spaces';
    END IF;
    
    -- Check domain
    IF LENGTH(SUBSTR(p_email, INSTR(p_email, '@') + 1)) < 3 THEN
        RETURN 'ERROR: Invalid domain';
    END IF;
    
    -- Check for company domain (additional business rule)
    IF UPPER(p_email) NOT LIKE '%@COMPANY.COM' THEN
        DBMS_OUTPUT.PUT_LINE('Warning: Non-company email detected: ' || p_email);
    END IF;
    
    RETURN 'VALID';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: Validation failed - ' || SQLERRM;
END validate_email;
/
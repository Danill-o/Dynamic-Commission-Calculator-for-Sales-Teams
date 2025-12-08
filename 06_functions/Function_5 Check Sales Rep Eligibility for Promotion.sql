-- ============================================
-- Function: CHECK_PROMOTION_ELIGIBILITY
-- Purpose: Check if sales rep is eligible for promotion
-- Parameters: p_rep_id IN - Sales Rep ID
-- Returns: Eligibility status and reason
-- ============================================
CREATE OR REPLACE FUNCTION check_promotion_eligibility(
    p_rep_id IN NUMBER
) RETURN VARCHAR2
IS
    v_hire_date DATE;
    v_months_employed NUMBER;
    v_total_sales NUMBER;
    v_success_rate NUMBER;
    v_avg_commission_rate NUMBER;
    v_current_rating VARCHAR2(100);
    v_eligibility_status VARCHAR2(500);
    
    -- Promotion criteria
    C_MIN_MONTHS CONSTANT NUMBER := 12; -- Minimum 1 year
    C_MIN_SALES CONSTANT NUMBER := 300000; -- Minimum sales
    C_MIN_SUCCESS_RATE CONSTANT NUMBER := 80; -- 80% success rate
    C_MIN_RATING CONSTANT VARCHAR2(10) := '★★★★☆'; -- 4 stars minimum
    
BEGIN
    -- Get rep information
    SELECT 
        sr.hire_date,
        COALESCE(SUM(CASE WHEN s.sale_status = 'COMPLETED' THEN s.unit_price * s.quantity ELSE 0 END), 0),
        SUM(CASE WHEN s.sale_status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0),
        sr.commission_rate,
        get_performance_rating(p_rep_id)
    INTO v_hire_date, v_total_sales, v_success_rate, 
         v_avg_commission_rate, v_current_rating
    FROM sales_rep sr
    LEFT JOIN sale s ON sr.rep_id = s.rep_id
    WHERE sr.rep_id = p_rep_id
    GROUP BY sr.hire_date, sr.commission_rate;
    
    -- Calculate months employed
    v_months_employed := MONTHS_BETWEEN(SYSDATE, v_hire_date);
    
    -- Build eligibility status
    v_eligibility_status := 'Eligibility Check for Rep ID ' || p_rep_id || ':' || CHR(10);
    
    -- Check criteria
    IF v_months_employed < C_MIN_MONTHS THEN
        v_eligibility_status := v_eligibility_status || 
            '✗ Minimum employment: ' || ROUND(v_months_employed, 1) || 
            ' months (Required: ' || C_MIN_MONTHS || ' months)' || CHR(10);
    ELSE
        v_eligibility_status := v_eligibility_status || 
            '✓ Minimum employment: ' || ROUND(v_months_employed, 1) || ' months' || CHR(10);
    END IF;
    
    IF v_total_sales < C_MIN_SALES THEN
        v_eligibility_status := v_eligibility_status || 
            '✗ Total sales: $' || ROUND(v_total_sales, 2) || 
            ' (Required: $' || C_MIN_SALES || ')' || CHR(10);
    ELSE
        v_eligibility_status := v_eligibility_status || 
            '✓ Total sales: $' || ROUND(v_total_sales, 2) || CHR(10);
    END IF;
    
    IF v_success_rate < C_MIN_SUCCESS_RATE THEN
        v_eligibility_status := v_eligibility_status || 
            '✗ Success rate: ' || ROUND(v_success_rate, 1) || 
            '% (Required: ' || C_MIN_SUCCESS_RATE || '%)' || CHR(10);
    ELSE
        v_eligibility_status := v_eligibility_status || 
            '✓ Success rate: ' || ROUND(v_success_rate, 1) || '%' || CHR(10);
    END IF;
    
    IF v_current_rating NOT LIKE C_MIN_RATING || '%' AND 
       v_current_rating NOT LIKE '★★★★★%' THEN
        v_eligibility_status := v_eligibility_status || 
            '✗ Performance rating: ' || v_current_rating || 
            ' (Required: ' || C_MIN_RATING || ' or better)' || CHR(10);
    ELSE
        v_eligibility_status := v_eligibility_status || 
            '✓ Performance rating: ' || v_current_rating || CHR(10);
    END IF;
    
    -- Overall eligibility
    IF v_months_employed >= C_MIN_MONTHS AND
       v_total_sales >= C_MIN_SALES AND
       v_success_rate >= C_MIN_SUCCESS_RATE AND
       (v_current_rating LIKE C_MIN_RATING || '%' OR 
        v_current_rating LIKE '★★★★★%') THEN
        v_eligibility_status := v_eligibility_status || CHR(10) ||
            '✅ ELIGIBLE FOR PROMOTION';
    ELSE
        v_eligibility_status := v_eligibility_status || CHR(10) ||
            '❌ NOT ELIGIBLE FOR PROMOTION';
    END IF;
    
    RETURN v_eligibility_status;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERROR: Sales Rep ID ' || p_rep_id || ' not found';
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END check_promotion_eligibility;
/
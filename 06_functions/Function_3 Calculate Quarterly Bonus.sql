-- ============================================
-- Function: CALCULATE_QUARTERLY_BONUS
-- Purpose: Calculate quarterly performance bonus
-- Parameters: 
--   p_rep_id IN - Sales Rep ID
--   p_quarter IN - Quarter (1-4)
--   p_year IN - Year
-- Returns: Bonus amount
-- ============================================
CREATE OR REPLACE FUNCTION calculate_quarterly_bonus(
    p_rep_id IN NUMBER,
    p_quarter IN NUMBER,
    p_year IN NUMBER
) RETURN NUMBER
IS
    v_quarter_start DATE;
    v_quarter_end DATE;
    v_total_sales NUMBER := 0;
    v_quota NUMBER := 100000; -- Default quarterly quota
    v_bonus_rate NUMBER := 0.05; -- 5% bonus for exceeding quota
    v_bonus_amount NUMBER := 0;
    v_rep_exists NUMBER;
    
    -- Quarter date ranges
    FUNCTION get_quarter_dates(
        p_qtr IN NUMBER,
        p_yr IN NUMBER
    ) RETURN VARCHAR2
    IS
    BEGIN
        CASE p_qtr
            WHEN 1 THEN RETURN TO_DATE(p_yr || '-01-01', 'YYYY-MM-DD') || ':' || 
                          TO_DATE(p_yr || '-03-31', 'YYYY-MM-DD');
            WHEN 2 THEN RETURN TO_DATE(p_yr || '-04-01', 'YYYY-MM-DD') || ':' || 
                          TO_DATE(p_yr || '-06-30', 'YYYY-MM-DD');
            WHEN 3 THEN RETURN TO_DATE(p_yr || '-07-01', 'YYYY-MM-DD') || ':' || 
                          TO_DATE(p_yr || '-09-30', 'YYYY-MM-DD');
            WHEN 4 THEN RETURN TO_DATE(p_yr || '-10-01', 'YYYY-MM-DD') || ':' || 
                          TO_DATE(p_yr || '-12-31', 'YYYY-MM-DD');
            ELSE RETURN NULL;
        END CASE;
    END;
    
BEGIN
    -- Validate quarter
    IF p_quarter < 1 OR p_quarter > 4 THEN
        RETURN 0;
    END IF;
    
    -- Check if rep exists and is active
    SELECT COUNT(*) INTO v_rep_exists
    FROM sales_rep
    WHERE rep_id = p_rep_id
      AND status = 'ACTIVE';
    
    IF v_rep_exists = 0 THEN
        RETURN 0;
    END IF;
    
    -- Parse quarter dates
    v_quarter_start := TO_DATE(SUBSTR(get_quarter_dates(p_quarter, p_year), 1, 10), 'YYYY-MM-DD');
    v_quarter_end := TO_DATE(SUBSTR(get_quarter_dates(p_quarter, p_year), 12), 'YYYY-MM-DD');
    
    -- Calculate total sales for quarter
    SELECT COALESCE(SUM(s.unit_price * s.quantity), 0)
    INTO v_total_sales
    FROM sale s
    WHERE s.rep_id = p_rep_id
      AND s.sale_date BETWEEN v_quarter_start AND v_quarter_end
      AND s.sale_status = 'COMPLETED';
    
    -- Get department-specific quota
    BEGIN
        SELECT d.budget * 0.25 INTO v_quota -- 25% of department budget
        FROM sales_rep sr
        JOIN department d ON sr.department_id = d.dept_id
        WHERE sr.rep_id = p_rep_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_quota := 100000; -- Default
    END;
    
    -- Calculate bonus if quota exceeded
    IF v_total_sales > v_quota THEN
        v_bonus_amount := (v_total_sales - v_quota) * v_bonus_rate;
        
        -- Cap bonus at 50% of base salary
        DECLARE
            v_base_salary NUMBER;
        BEGIN
            SELECT base_salary INTO v_base_salary
            FROM sales_rep
            WHERE rep_id = p_rep_id;
            
            v_bonus_amount := LEAST(v_bonus_amount, v_base_salary * 0.5);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;
    
    RETURN ROUND(v_bonus_amount, 2);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END calculate_quarterly_bonus;
/
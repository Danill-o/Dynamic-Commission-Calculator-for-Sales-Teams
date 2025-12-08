-- ============================================
-- Function: GET_PERFORMANCE_RATING
-- Purpose: Calculate performance rating based on multiple metrics
-- Parameters: p_rep_id IN - Sales Rep ID
-- Returns: Performance rating (1-5 stars)
-- ============================================
CREATE OR REPLACE FUNCTION get_performance_rating(
    p_rep_id IN NUMBER
) RETURN VARCHAR2
IS
    v_total_sales NUMBER := 0;
    v_average_sale NUMBER := 0;
    v_sales_count NUMBER := 0;
    v_success_rate NUMBER := 0;
    v_commission_earned NUMBER := 0;
    v_rating_score NUMBER := 0;
    v_rating VARCHAR2(10);
    
    -- Weightage for different metrics
    C_SALES_VOLUME_WEIGHT CONSTANT NUMBER := 0.4;
    C_AVG_SALE_WEIGHT CONSTANT NUMBER := 0.3;
    C_SUCCESS_RATE_WEIGHT CONSTANT NUMBER := 0.2;
    C_COMMISSION_WEIGHT CONSTANT NUMBER := 0.1;
    
BEGIN
    -- Get sales metrics from last 6 months
    SELECT 
        COALESCE(SUM(CASE WHEN s.sale_status = 'COMPLETED' THEN s.unit_price * s.quantity ELSE 0 END), 0),
        COALESCE(AVG(CASE WHEN s.sale_status = 'COMPLETED' THEN s.unit_price * s.quantity END), 0),
        COUNT(*),
        SUM(CASE WHEN s.sale_status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0),
        COALESCE(SUM(cc.commission_amount), 0)
    INTO v_total_sales, v_average_sale, v_sales_count, 
         v_success_rate, v_commission_earned
    FROM sale s
    LEFT JOIN commission_calculation cc ON s.sale_id = cc.sale_id
    WHERE s.rep_id = p_rep_id
      AND s.sale_date >= ADD_MONTHS(SYSDATE, -6);
    
    -- Normalize metrics to 0-100 scale
    DECLARE
        v_max_sales NUMBER;
        v_max_avg_sale NUMBER;
        v_max_commission NUMBER;
    BEGIN
        -- Get department maximums for normalization
        SELECT 
            MAX(total_sales),
            MAX(avg_sale),
            MAX(total_commission)
        INTO v_max_sales, v_max_avg_sale, v_max_commission
        FROM (
            SELECT 
                sr.rep_id,
                COALESCE(SUM(CASE WHEN s.sale_status = 'COMPLETED' THEN s.unit_price * s.quantity ELSE 0 END), 0) AS total_sales,
                COALESCE(AVG(CASE WHEN s.sale_status = 'COMPLETED' THEN s.unit_price * s.quantity END), 0) AS avg_sale,
                COALESCE(SUM(cc.commission_amount), 0) AS total_commission
            FROM sales_rep sr
            LEFT JOIN sale s ON sr.rep_id = s.rep_id
            LEFT JOIN commission_calculation cc ON s.sale_id = cc.sale_id
            WHERE sr.department_id = (
                SELECT department_id FROM sales_rep WHERE rep_id = p_rep_id
            )
              AND s.sale_date >= ADD_MONTHS(SYSDATE, -6)
            GROUP BY sr.rep_id
        );
        
        -- Avoid division by zero
        v_max_sales := GREATEST(v_max_sales, 1);
        v_max_avg_sale := GREATEST(v_max_avg_sale, 1);
        v_max_commission := GREATEST(v_max_commission, 1);
        
        -- Calculate weighted score
        v_rating_score := 
            (v_total_sales / v_max_sales * 100) * C_SALES_VOLUME_WEIGHT +
            (v_average_sale / v_max_avg_sale * 100) * C_AVG_SALE_WEIGHT +
            v_success_rate * C_SUCCESS_RATE_WEIGHT +
            (v_commission_earned / v_max_commission * 100) * C_COMMISSION_WEIGHT;
            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_rating_score := 50; -- Default score
    END;
    
    -- Convert score to star rating
    IF v_rating_score >= 90 THEN
        v_rating := '★★★★★'; -- 5 stars
    ELSIF v_rating_score >= 80 THEN
        v_rating := '★★★★☆'; -- 4 stars
    ELSIF v_rating_score >= 70 THEN
        v_rating := '★★★☆☆'; -- 3 stars
    ELSIF v_rating_score >= 60 THEN
        v_rating := '★★☆☆☆'; -- 2 stars
    ELSE
        v_rating := '★☆☆☆☆'; -- 1 star
    END IF;
    
    RETURN v_rating || ' (' || ROUND(v_rating_score, 1) || '%)';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N/A';
END get_performance_rating;
/
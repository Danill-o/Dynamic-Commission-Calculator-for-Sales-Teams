-- ============================================
-- Parameterized Cursor Example
-- Purpose: Generate performance report for a specific department
-- ============================================
DECLARE
    -- Parameterized cursor declaration
    CURSOR c_dept_performance (
        p_dept_id NUMBER,
        p_start_date DATE,
        p_end_date DATE
    ) IS
        SELECT 
            sr.rep_id,
            sr.first_name || ' ' || sr.last_name AS sales_rep,
            COUNT(DISTINCT s.sale_id) AS total_sales,
            SUM(CASE WHEN s.sale_status = 'COMPLETED' 
                     THEN s.unit_price * s.quantity ELSE 0 END) AS total_revenue,
            AVG(CASE WHEN s.sale_status = 'COMPLETED' 
                     THEN s.unit_price * s.quantity END) AS avg_sale,
            COALESCE(SUM(cc.commission_amount), 0) AS total_commission,
            get_performance_rating(sr.rep_id) AS performance_rating
        FROM sales_rep sr
        LEFT JOIN sale s ON sr.rep_id = s.rep_id
        LEFT JOIN commission_calculation cc ON s.sale_id = cc.sale_id
        WHERE sr.department_id = p_dept_id
          AND s.sale_date BETWEEN p_start_date AND p_end_date
        GROUP BY sr.rep_id, sr.first_name, sr.last_name
        ORDER BY total_revenue DESC;
    
    v_dept_id NUMBER := 101; -- North America Sales
    v_start_date DATE := ADD_MONTHS(SYSDATE, -3); -- Last quarter
    v_end_date DATE := SYSDATE;
    v_total_dept_revenue NUMBER := 0;
    v_total_dept_commission NUMBER := 0;
    v_rep_count NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('Department Performance Report');
    DBMS_OUTPUT.PUT_LINE('Department ID: ' || v_dept_id);
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(v_start_date, 'YYYY-MM-DD') || 
                        ' to ' || TO_CHAR(v_end_date, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('Rep ID | Sales Rep | Revenue | Commission | Rating');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    
    -- Open cursor with parameters
    FOR perf_rec IN c_dept_performance(v_dept_id, v_start_date, v_end_date) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(perf_rec.rep_id, 7) || '| ' ||
            RPAD(perf_rec.sales_rep, 15) || '| ' ||
            RPAD('$' || ROUND(perf_rec.total_revenue, 2), 10) || '| ' ||
            RPAD('$' || ROUND(perf_rec.total_commission, 2), 10) || '| ' ||
            perf_rec.performance_rating
        );
        
        -- Accumulate totals
        v_total_dept_revenue := v_total_dept_revenue + perf_rec.total_revenue;
        v_total_dept_commission := v_total_dept_commission + perf_rec.total_commission;
        v_rep_count := v_rep_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('SUMMARY:');
    DBMS_OUTPUT.PUT_LINE('Total Sales Reps: ' || v_rep_count);
    DBMS_OUTPUT.PUT_LINE('Total Department Revenue: $' || ROUND(v_total_dept_revenue, 2));
    DBMS_OUTPUT.PUT_LINE('Total Department Commission: $' || ROUND(v_total_dept_commission, 2));
    DBMS_OUTPUT.PUT_LINE('Average Commission per Rep: $' || 
                        ROUND(v_total_dept_commission / NULLIF(v_rep_count, 0), 2));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating report: ' || SQLERRM);
END;
/
-- ============================================
-- Package: COMMISSION_PKG
-- Specification
-- Purpose: Group related commission procedures and functions
-- ============================================
CREATE OR REPLACE PACKAGE commission_pkg AS
    
    -- Global constants
    g_max_commission_rate CONSTANT NUMBER := 20;
    g_min_sales_for_bonus CONSTANT NUMBER := 50000;
    
    -- Commission calculation procedures
    PROCEDURE calculate_all_commissions(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_records_processed OUT NUMBER,
        p_total_commission OUT NUMBER
    );
    
    PROCEDURE recalculate_commission(
        p_calc_id IN NUMBER,
        p_new_rate IN NUMBER,
        p_success OUT CHAR,
        p_message OUT VARCHAR2
    );
    
    -- Reporting procedures
    PROCEDURE generate_commission_statement(
        p_rep_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_statement_data OUT SYS_REFCURSOR
    );
    
    -- Validation functions
    FUNCTION is_valid_commission_rate(
        p_rate IN NUMBER
    ) RETURN BOOLEAN;
    
    FUNCTION calculate_commission_with_bonus(
        p_sale_amount IN NUMBER,
        p_base_rate IN NUMBER
    ) RETURN NUMBER;
    
    -- Utility functions
    FUNCTION format_currency(
        p_amount IN NUMBER
    ) RETURN VARCHAR2;
    
    FUNCTION get_commission_summary(
        p_rep_id IN NUMBER,
        p_period IN VARCHAR2
    ) RETURN VARCHAR2;
    
    -- Error handling
    PROCEDURE log_commission_error(
        p_error_code IN NUMBER,
        p_error_message IN VARCHAR2,
        p_sale_id IN NUMBER DEFAULT NULL,
        p_rep_id IN NUMBER DEFAULT NULL
    );
    
    -- Commission statistics
    FUNCTION get_department_stats(
        p_dept_id IN NUMBER
    ) RETURN SYS_REFCURSOR;
    
    -- Public variables
    v_last_calculation_date DATE;
    v_debug_mode BOOLEAN := FALSE;
    
END commission_pkg;
/
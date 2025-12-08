-- ============================================
-- Window Functions for Sales Analysis
-- ============================================

-- 1. ROW_NUMBER() - Rank sales reps by monthly sales
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS month,
    sr.rep_id,
    sr.first_name || ' ' || sr.last_name AS sales_rep,
    SUM(s.unit_price * s.quantity) AS monthly_sales,
    ROW_NUMBER() OVER (
        PARTITION BY TO_CHAR(s.sale_date, 'YYYY-MM')
        ORDER BY SUM(s.unit_price * s.quantity) DESC
    ) AS monthly_rank,
    RANK() OVER (
        PARTITION BY TO_CHAR(s.sale_date, 'YYYY-MM')
        ORDER BY SUM(s.unit_price * s.quantity) DESC
    ) AS rank_with_ties,
    DENSE_RANK() OVER (
        PARTITION BY TO_CHAR(s.sale_date, 'YYYY-MM')
        ORDER BY SUM(s.unit_price * s.quantity) DESC
    ) AS dense_rank
FROM sale s
JOIN sales_rep sr ON s.rep_id = sr.rep_id
WHERE s.sale_status = 'COMPLETED'
  AND s.sale_date >= ADD_MONTHS(SYSDATE, -6)
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), sr.rep_id, sr.first_name, sr.last_name
ORDER BY month DESC, monthly_sales DESC;

-- 2. LAG() and LEAD() - Compare monthly performance
SELECT 
    month,
    region_name,
    monthly_revenue,
    LAG(monthly_revenue, 1) OVER (
        PARTITION BY region_name
        ORDER BY month
    ) AS previous_month,
    monthly_revenue - LAG(monthly_revenue, 1) OVER (
        PARTITION BY region_name
        ORDER BY month
    ) AS monthly_change,
    LEAD(monthly_revenue, 1) OVER (
        PARTITION BY region_name
        ORDER BY month
    ) AS next_month,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 1) OVER (
            PARTITION BY region_name
            ORDER BY month
        )) / LAG(monthly_revenue, 1) OVER (
            PARTITION BY region_name
            ORDER BY month
        ) * 100, 2
    ) AS percent_change
FROM (
    SELECT 
        TO_CHAR(s.sale_date, 'YYYY-MM') AS month,
        r.region_name,
        SUM(s.unit_price * s.quantity) AS monthly_revenue
    FROM sale s
    JOIN sales_rep sr ON s.rep_id = sr.rep_id
    JOIN region r ON sr.region_id = r.region_id
    WHERE s.sale_status = 'COMPLETED'
    GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), r.region_name
)
ORDER BY region_name, month;

-- 3. Running Totals and Averages
SELECT 
    sale_date,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    AVG(daily_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_avg,
    MAX(daily_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS thirty_day_max
FROM (
    SELECT 
        TRUNC(s.sale_date) AS sale_date,
        SUM(s.unit_price * s.quantity) AS daily_revenue
    FROM sale s
    WHERE s.sale_status = 'COMPLETED'
    GROUP BY TRUNC(s.sale_date)
)
ORDER BY sale_date;

-- 4. Percent of Total by Department
SELECT 
    d.dept_name,
    SUM(s.unit_price * s.quantity) AS dept_revenue,
    ROUND(
        SUM(s.unit_price * s.quantity) / 
        SUM(SUM(s.unit_price * s.quantity)) OVER () * 100, 2
    ) AS percent_of_total,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY SUM(s.unit_price * s.quantity)
        ) * 100, 2
    ) AS percentile_rank
FROM sale s
JOIN sales_rep sr ON s.rep_id = sr.rep_id
JOIN department d ON sr.department_id = d.dept_id
WHERE s.sale_status = 'COMPLETED'
  AND s.sale_date >= ADD_MONTHS(SYSDATE, -3)
GROUP BY d.dept_name
ORDER BY dept_revenue DESC;

-- 5. Moving Averages for Commission Trends
SELECT 
    calculation_date,
    daily_commission,
    AVG(daily_commission) OVER (
        ORDER BY calculation_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_moving_avg,
    AVG(daily_commission) OVER (
        ORDER BY calculation_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS thirty_day_moving_avg,
    STDDEV(daily_commission) OVER (
        ORDER BY calculation_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS thirty_day_stddev
FROM (
    SELECT 
        TRUNC(cc.calculation_date) AS calculation_date,
        SUM(cc.commission_amount) AS daily_commission
    FROM commission_calculation cc
    WHERE cc.status IN ('CALCULATED', 'PAID')
    GROUP BY TRUNC(cc.calculation_date)
)
ORDER BY calculation_date;
-- ============================================
-- Dynamic Commission Calculator - Test Queries
-- ============================================

-- Test 1: Basic Retrieval
SELECT * FROM SALES_REP WHERE ROWNUM <= 5;
SELECT * FROM SALE WHERE ROWNUM <= 5;

-- Test 2: Joins (Multi-table queries)
-- Sales with rep and product details
SELECT s.sale_id, s.sale_date, 
       sr.first_name || ' ' || sr.last_name AS sales_rep,
       p.product_name, p.category,
       s.quantity, s.unit_price, s.total_amount
FROM SALE s
JOIN SALES_REP sr ON s.rep_id = sr.rep_id
JOIN PRODUCT p ON s.product_id = p.product_id
WHERE s.sale_status = 'COMPLETED'
ORDER BY s.sale_date DESC;

-- Test 3: Aggregations (GROUP BY)
-- Monthly sales summary
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS month,
       COUNT(*) AS total_sales,
       SUM(s.unit_price * s.quantity) AS total_revenue,
       AVG(s.unit_price * s.quantity) AS average_sale
FROM SALE s
WHERE s.sale_status = 'COMPLETED'
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY month DESC;

-- Commission by department
SELECT d.dept_name,
       COUNT(cc.calc_id) AS total_commissions,
       SUM(cc.total_payout) AS total_payouts,
       AVG(cc.commission_rate) AS avg_commission_rate
FROM COMMISSION_CALCULATION cc
JOIN SALES_REP sr ON cc.rep_id = sr.rep_id
JOIN DEPARTMENT d ON sr.department_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total_payouts DESC;

-- Test 4: Subqueries
-- Sales reps with above average commission
SELECT sr.rep_id, sr.first_name, sr.last_name,
       sr.commission_rate,
       (SELECT AVG(commission_rate) FROM SALES_REP) AS avg_commission_rate
FROM SALES_REP sr
WHERE sr.commission_rate > (SELECT AVG(commission_rate) FROM SALES_REP)
ORDER BY sr.commission_rate DESC;

-- Products with highest sales
SELECT p.product_name,
       (SELECT COUNT(*) FROM SALE s WHERE s.product_id = p.product_id) AS total_sales,
       (SELECT SUM(s.unit_price * s.quantity) FROM SALE s WHERE s.product_id = p.product_id) AS total_revenue
FROM PRODUCT p
ORDER BY total_revenue DESC NULLS LAST;

-- Test 5: Window Functions (for Phase VI preview)
-- Rank sales reps by total sales
SELECT sr.rep_id, sr.first_name, sr.last_name,
       SUM(s.total_amount) AS total_sales,
       RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS sales_rank,
       DENSE_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS dense_sales_rank,
       ROUND(PERCENT_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) * 100, 2) AS percentile
FROM SALE s
JOIN SALES_REP sr ON s.rep_id = sr.rep_id
WHERE s.sale_status = 'COMPLETED'
GROUP BY sr.rep_id, sr.first_name, sr.last_name
ORDER BY total_sales DESC;

-- Monthly sales with running total
SELECT TO_CHAR(sale_date, 'YYYY-MM') AS month,
       SUM(total_amount) AS monthly_sales,
       SUM(SUM(total_amount)) OVER (ORDER BY TO_CHAR(sale_date, 'YYYY-MM')) AS running_total
FROM SALE
WHERE sale_status = 'COMPLETED'
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month;

-- Test 6: Data Quality Checks
-- Find sales with missing commission calculations
SELECT s.sale_id, s.sale_date, s.total_amount,
       sr.first_name || ' ' || sr.last_name AS sales_rep
FROM SALE s
JOIN SALES_REP sr ON s.rep_id = sr.rep_id
WHERE s.sale_status = 'COMPLETED'
  AND s.commission_calculated = 'N'
  AND NOT EXISTS (
      SELECT 1 FROM COMMISSION_CALCULATION cc 
      WHERE cc.sale_id = s.sale_id
  );

-- Test 7: Complex Business Logic
-- Calculate what commissions would be with different rules
SELECT cc.calc_id, cc.base_amount, cc.commission_rate AS current_rate,
       cr.commission_rate AS alternative_rate,
       cc.commission_amount AS current_commission,
       ROUND(cc.base_amount * (cr.commission_rate/100), 2) AS alternative_commission,
       ROUND(cc.commission_amount - ROUND(cc.base_amount * (cr.commission_rate/100), 2), 2) AS difference
FROM COMMISSION_CALCULATION cc
CROSS JOIN COMMISSION_RULE cr
WHERE cr.rule_id = 2  -- Tier 2 rule
  AND ROWNUM <= 10;
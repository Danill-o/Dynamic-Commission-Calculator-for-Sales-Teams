-- ============================================
-- Dynamic Commission Calculator - Data Validation
-- Created by: Daniel (ID: 2796)
-- ============================================

-- 1. Basic Count Validation
PROMPT ========== BASIC COUNT VALIDATION ==========
SELECT 'SALES_REP' AS table_name, COUNT(*) AS record_count FROM SALES_REP
UNION ALL
SELECT 'DEPARTMENT', COUNT(*) FROM DEPARTMENT
UNION ALL
SELECT 'REGION', COUNT(*) FROM REGION
UNION ALL
SELECT 'PRODUCT', COUNT(*) FROM PRODUCT
UNION ALL
SELECT 'SALE', COUNT(*) FROM SALE
UNION ALL
SELECT 'COMMISSION_RULE', COUNT(*) FROM COMMISSION_RULE
UNION ALL
SELECT 'COMMISSION_CALCULATION', COUNT(*) FROM COMMISSION_CALCULATION
UNION ALL
SELECT 'PAYOUT', COUNT(*) FROM PAYOUT
ORDER BY 1;

-- 2. Data Integrity Checks
PROMPT ========== DATA INTEGRITY CHECKS ==========
-- Check for NULL in required fields
SELECT 'SALES_REP: NULL first_name' AS check_description, COUNT(*) AS issue_count
FROM SALES_REP WHERE first_name IS NULL
UNION ALL
SELECT 'SALES_REP: NULL last_name', COUNT(*)
FROM SALES_REP WHERE last_name IS NULL
UNION ALL
SELECT 'SALE: NULL rep_id', COUNT(*)
FROM SALE WHERE rep_id IS NULL
UNION ALL
SELECT 'SALE: NULL product_id', COUNT(*)
FROM SALE WHERE product_id IS NULL;

-- 3. Foreign Key Relationship Validation
PROMPT ========== FOREIGN KEY VALIDATION ==========
-- Check for orphaned sales records
SELECT 'Orphaned SALE records' AS issue, COUNT(*) AS count
FROM SALE s
WHERE NOT EXISTS (SELECT 1 FROM SALES_REP sr WHERE sr.rep_id = s.rep_id)
   OR NOT EXISTS (SELECT 1 FROM PRODUCT p WHERE p.product_id = s.product_id);

-- Check for orphaned commission calculations
SELECT 'Orphaned COMMISSION_CALCULATION records' AS issue, COUNT(*) AS count
FROM COMMISSION_CALCULATION cc
WHERE NOT EXISTS (SELECT 1 FROM SALE s WHERE s.sale_id = cc.sale_id)
   OR NOT EXISTS (SELECT 1 FROM SALES_REP sr WHERE sr.rep_id = cc.rep_id);

-- 4. Business Rule Validation
PROMPT ========== BUSINESS RULE VALIDATION ==========
-- Check commission rate bounds
SELECT 'Invalid commission rate' AS check_description, rep_id, commission_rate
FROM SALES_REP 
WHERE commission_rate < 0 OR commission_rate > 100;

-- Check sale quantity
SELECT 'Invalid sale quantity' AS check_description, sale_id, quantity
FROM SALE 
WHERE quantity <= 0;

-- Check product price
SELECT 'Invalid product price' AS check_description, product_id, unit_price
FROM PRODUCT 
WHERE unit_price <= 0;

-- 5. Sample Data Verification
PROMPT ========== SAMPLE DATA VERIFICATION ==========
-- Show first 10 sales with details
SELECT s.sale_id, sr.first_name || ' ' || sr.last_name AS sales_rep,
       p.product_name, s.quantity, s.unit_price, s.total_amount,
       s.sale_date, s.sale_status
FROM SALE s
JOIN SALES_REP sr ON s.rep_id = sr.rep_id
JOIN PRODUCT p ON s.product_id = p.product_id
WHERE ROWNUM <= 10
ORDER BY s.sale_date DESC;

-- Show commission calculations for first 5 sales
SELECT cc.calc_id, s.sale_id, sr.first_name || ' ' || sr.last_name AS sales_rep,
       cc.base_amount, cc.commission_rate, cc.commission_amount,
       cc.bonus_amount, cc.total_payout, cc.status
FROM COMMISSION_CALCULATION cc
JOIN SALE s ON cc.sale_id = s.sale_id
JOIN SALES_REP sr ON cc.rep_id = sr.rep_id
WHERE ROWNUM <= 5
ORDER BY cc.calculation_date DESC;

-- 6. Aggregation Tests
PROMPT ========== AGGREGATION TESTS ==========
-- Total sales by region
SELECT r.region_name, COUNT(s.sale_id) AS total_sales,
       SUM(s.unit_price * s.quantity) AS total_revenue,
       AVG(s.unit_price * s.quantity) AS avg_sale_amount
FROM SALE s
JOIN SALES_REP sr ON s.rep_id = sr.rep_id
JOIN REGION r ON sr.region_id = r.region_id
WHERE s.sale_status = 'COMPLETED'
GROUP BY r.region_name
ORDER BY total_revenue DESC;

-- Commission summary by sales rep
SELECT sr.rep_id, sr.first_name || ' ' || sr.last_name AS sales_rep,
       COUNT(cc.calc_id) AS commissions_calculated,
       SUM(cc.commission_amount) AS total_commission,
       SUM(cc.bonus_amount) AS total_bonus,
       SUM(cc.total_payout) AS total_payout
FROM COMMISSION_CALCULATION cc
JOIN SALES_REP sr ON cc.rep_id = sr.rep_id
GROUP BY sr.rep_id, sr.first_name, sr.last_name
ORDER BY total_payout DESC;

-- 7. Constraint Validation
PROMPT ========== CONSTRAINT VALIDATION ==========
-- Check for duplicate emails
SELECT email, COUNT(*) AS duplicate_count
FROM SALES_REP
GROUP BY email
HAVING COUNT(*) > 1;

-- Check status values
SELECT 'Invalid sales rep status' AS check, status, COUNT(*)
FROM SALES_REP
WHERE status NOT IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE')
GROUP BY status;

SELECT 'Invalid sale status' AS check, sale_status, COUNT(*)
FROM SALE
WHERE sale_status NOT IN ('PENDING', 'COMPLETED', 'CANCELLED', 'REFUNDED')
GROUP BY sale_status;

-- 8. Data Completeness Check
PROMPT ========== DATA COMPLETENESS ==========
-- Check percentage of null values
SELECT 'SALES_REP phone null' AS field, 
       ROUND((COUNT(CASE WHEN phone IS NULL THEN 1 END) / COUNT(*) * 100), 2) AS null_percentage
FROM SALES_REP
UNION ALL
SELECT 'SALE customer_id null', 
       ROUND((COUNT(CASE WHEN customer_id IS NULL THEN 1 END) / COUNT(*) * 100), 2)
FROM SALE
UNION ALL
SELECT 'COMMISSION_CALCULATION paid_date null', 
       ROUND((COUNT(CASE WHEN paid_date IS NULL THEN 1 END) / COUNT(*) * 100), 2)
FROM COMMISSION_CALCULATION;

PROMPT ========== VALIDATION COMPLETED ==========
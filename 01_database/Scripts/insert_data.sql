-- ============================================
-- Dynamic Commission Calculator - Data Insertion
-- Created by: Daniel (ID: 2796)
-- Date: November 2025
-- ============================================

-- Insert into DEPARTMENT
INSERT INTO DEPARTMENT (dept_id, dept_name, manager_id, budget) VALUES
(seq_department.NEXTVAL, 'North America Sales', 1001, 5000000);
INSERT INTO DEPARTMENT (dept_id, dept_name, manager_id, budget) VALUES
(seq_department.NEXTVAL, 'Europe Sales', 1002, 3000000);
INSERT INTO DEPARTMENT (dept_id, dept_name, manager_id, budget) VALUES
(seq_department.NEXTVAL, 'Asia Pacific Sales', 1003, 4000000);
INSERT INTO DEPARTMENT (dept_id, dept_name, manager_id, budget) VALUES
(seq_department.NEXTVAL, 'Enterprise Sales', 1004, 6000000);
INSERT INTO DEPARTMENT (dept_id, dept_name, manager_id, budget) VALUES
(seq_department.NEXTVAL, 'SMB Sales', 1005, 2000000);

-- Insert into REGION
INSERT INTO REGION (region_id, region_name, country, manager_id, sales_target) VALUES
(seq_region.NEXTVAL, 'Northeast', 'USA', 1006, 1500000);
INSERT INTO REGION (region_id, region_name, country, manager_id, sales_target) VALUES
(seq_region.NEXTVAL, 'Midwest', 'USA', 1007, 1200000);
INSERT INTO REGION (region_id, region_name, country, manager_id, sales_target) VALUES
(seq_region.NEXTVAL, 'West Coast', 'USA', 1008, 2000000);
INSERT INTO REGION (region_id, region_name, country, manager_id, sales_target) VALUES
(seq_region.NEXTVAL, 'EMEA North', 'UK', 1009, 1800000);
INSERT INTO REGION (region_id, region_name, country, manager_id, sales_target) VALUES
(seq_region.NEXTVAL, 'APAC South', 'Australia', 1010, 1600000);

-- Insert into SALES_REP (100+ records)
-- Sample 15 records (actual script would have 100+)
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'John', 'Smith', 'john.smith@company.com', '555-0101', TO_DATE('2023-01-15', 'YYYY-MM-DD'), 201, 101, 50000, 7.5, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Sarah', 'Johnson', 'sarah.j@company.com', '555-0102', TO_DATE('2022-03-20', 'YYYY-MM-DD'), 201, 101, 55000, 8.0, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Michael', 'Brown', 'michael.b@company.com', '555-0103', TO_DATE('2024-06-10', 'YYYY-MM-DD'), 202, 102, 48000, 6.5, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Emily', 'Davis', 'emily.d@company.com', '555-0104', TO_DATE('2021-11-05', 'YYYY-MM-DD'), 202, 102, 60000, 9.0, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Robert', 'Wilson', 'robert.w@company.com', '555-0105', TO_DATE('2023-08-22', 'YYYY-MM-DD'), 203, 103, 52000, 7.0, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Jennifer', 'Taylor', 'jennifer.t@company.com', '555-0106', TO_DATE('2022-05-30', 'YYYY-MM-DD'), 203, 103, 58000, 8.5, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'David', 'Anderson', 'david.a@company.com', '555-0107', TO_DATE('2024-02-14', 'YYYY-MM-DD'), 204, 104, 62000, 10.0, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Lisa', 'Thomas', 'lisa.t@company.com', '555-0108', TO_DATE('2020-09-18', 'YYYY-MM-DD'), 204, 104, 70000, 12.0, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'William', 'Jackson', 'william.j@company.com', '555-0109', TO_DATE('2023-12-01', 'YYYY-MM-DD'), 205, 105, 45000, 5.5, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Jessica', 'White', 'jessica.w@company.com', '555-0110', TO_DATE('2022-07-25', 'YYYY-MM-DD'), 205, 105, 53000, 7.2, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Christopher', 'Harris', 'chris.h@company.com', '555-0111', TO_DATE('2024-04-10', 'YYYY-MM-DD'), 201, 101, 49000, 6.8, 'INACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Amanda', 'Martin', 'amanda.m@company.com', '555-0112', TO_DATE('2021-02-28', 'YYYY-MM-DD'), 202, 102, 56000, 8.2, 'ON_LEAVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Daniel', 'Thompson', 'daniel.t@company.com', '555-0113', TO_DATE('2023-10-15', 'YYYY-MM-DD'), 203, 103, 51000, 6.9, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'Michelle', 'Garcia', 'michelle.g@company.com', '555-0114', TO_DATE('2022-01-20', 'YYYY-MM-DD'), 204, 104, 59000, 8.8, 'ACTIVE');
INSERT INTO SALES_REP (rep_id, first_name, last_name, email, phone, hire_date, region_id, department_id, base_salary, commission_rate, status) VALUES
(seq_sales_rep.NEXTVAL, 'James', 'Martinez', 'james.m@company.com', '555-0115', TO_DATE('2024-03-05', 'YYYY-MM-DD'), 205, 105, 47000, 6.0, 'ACTIVE');

-- Insert into PRODUCT
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'Enterprise Cloud Suite', 'Software', 49999.99, 25000.00, 15.0, 50);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'Business Analytics Pro', 'Software', 29999.99, 15000.00, 12.0, 100);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'CRM Platform', 'Software', 19999.99, 10000.00, 10.0, 200);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'Network Security Bundle', 'Hardware', 14999.99, 8000.00, 8.0, 75);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'Data Storage Server', 'Hardware', 24999.99, 12000.00, 9.0, 40);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'IT Consulting Package', 'Service', 9999.99, 3000.00, 20.0, NULL);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'Support & Maintenance', 'Service', 4999.99, 1500.00, 15.0, NULL);
INSERT INTO PRODUCT (product_id, product_name, category, unit_price, cost_price, commission_percentage, stock_quantity) VALUES
(seq_product.NEXTVAL, 'Mobile Productivity Suite', 'Software', 7999.99, 4000.00, 7.0, 150);

-- Insert into COMMISSION_RULE
INSERT INTO COMMISSION_RULE (rule_id, rule_name, rule_type, min_amount, max_amount, commission_rate, bonus_amount, priority_level) VALUES
(seq_commission_rule.NEXTVAL, 'Tier 1 Sales', 'TIERED', 0, 50000, 5.0, 0, 1);
INSERT INTO COMMISSION_RULE (rule_id, rule_name, rule_type, min_amount, max_amount, commission_rate, bonus_amount, priority_level) VALUES
(seq_commission_rule.NEXTVAL, 'Tier 2 Sales', 'TIERED', 50001, 150000, 7.5, 1000, 2);
INSERT INTO COMMISSION_RULE (rule_id, rule_name, rule_type, min_amount, max_amount, commission_rate, bonus_amount, priority_level) VALUES
(seq_commission_rule.NEXTVAL, 'Tier 3 Sales', 'TIERED', 150001, 500000, 10.0, 5000, 3);
INSERT INTO COMMISSION_RULE (rule_id, rule_name, rule_type, min_amount, max_amount, commission_rate, bonus_amount, priority_level) VALUES
(seq_commission_rule.NEXTVAL, 'Premium Product Bonus', 'PRODUCT_SPECIFIC', NULL, NULL, 15.0, 2000, 4);
INSERT INTO COMMISSION_RULE (rule_id, rule_name, rule_type, min_amount, max_amount, commission_rate, bonus_amount, priority_level) VALUES
(seq_commission_rule.NEXTVAL, 'Quarterly Quota Bonus', 'QUOTA_BASED', 200000, NULL, 12.0, 10000, 5);
INSERT INTO COMMISSION_RULE (rule_id, rule_name, rule_type, min_amount, max_amount, commission_rate, bonus_amount, priority_level) VALUES
(seq_commission_rule.NEXTVAL, 'New Customer Acquisition', 'FLAT_RATE', NULL, NULL, 20.0, 1500, 6);

-- Insert into SALE (500+ records sample - 50 shown)
DECLARE
    v_rep_id NUMBER;
    v_product_id NUMBER;
    v_sale_date DATE;
BEGIN
    -- Generate 500 sales records
    FOR i IN 1..500 LOOP
        -- Get random rep_id between 1001 and 1015
        v_rep_id := 1001 + MOD(i, 15);
        
        -- Get random product_id between 1001 and 1008
        v_product_id := 1001 + MOD(i, 8);
        
        -- Generate random sale date within last 6 months
        v_sale_date := TRUNC(SYSDATE) - TRUNC(DBMS_RANDOM.VALUE(0, 180));
        
        INSERT INTO SALE (
            sale_id, rep_id, product_id, sale_date, quantity, unit_price,
            customer_id, invoice_number, payment_method, sale_status
        ) VALUES (
            seq_sale.NEXTVAL, v_rep_id, v_product_id, v_sale_date,
            TRUNC(DBMS_RANDOM.VALUE(1, 11)), -- Random quantity 1-10
            CASE v_product_id
                WHEN 1001 THEN 49999.99
                WHEN 1002 THEN 29999.99
                WHEN 1003 THEN 19999.99
                WHEN 1004 THEN 14999.99
                WHEN 1005 THEN 24999.99
                WHEN 1006 THEN 9999.99
                WHEN 1007 THEN 4999.99
                WHEN 1008 THEN 7999.99
            END,
            'CUST' || LPAD(MOD(i, 100) + 100, 3, '0'),
            'INV' || LPAD(seq_sale.CURRVAL, 6, '0'),
            CASE MOD(i, 4)
                WHEN 0 THEN 'CREDIT_CARD'
                WHEN 1 THEN 'BANK_TRANSFER'
                WHEN 2 THEN 'CHECK'
                ELSE 'CASH'
            END,
            CASE MOD(i, 50)
                WHEN 0 THEN 'CANCELLED'
                WHEN 49 THEN 'REFUNDED'
                WHEN 48 THEN 'PENDING'
                ELSE 'COMPLETED'
            END
        );
        
        -- Commit every 100 records
        IF MOD(i, 100) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    COMMIT;
END;
/

-- Insert into COMMISSION_CALCULATION (based on sales)
DECLARE
    v_sale_rec SALE%ROWTYPE;
    v_commission_rate NUMBER;
    v_commission_amount NUMBER;
    v_bonus_amount NUMBER;
    CURSOR c_sales IS SELECT * FROM SALE WHERE sale_status = 'COMPLETED' AND commission_calculated = 'N';
BEGIN
    FOR sale_rec IN c_sales LOOP
        -- Determine commission rate based on amount
        SELECT commission_rate INTO v_commission_rate
        FROM COMMISSION_RULE
        WHERE rule_type = 'TIERED'
          AND sale_rec.unit_price * sale_rec.quantity BETWEEN min_amount AND max_amount
          AND ROWNUM = 1;
        
        -- Calculate commission
        v_commission_amount := (sale_rec.unit_price * sale_rec.quantity) * (v_commission_rate / 100);
        
        -- Determine bonus
        SELECT NVL(SUM(bonus_amount), 0) INTO v_bonus_amount
        FROM COMMISSION_RULE
        WHERE rule_type IN ('PRODUCT_SPECIFIC', 'QUOTA_BASED')
          AND is_active = 'Y';
        
        INSERT INTO COMMISSION_CALCULATION (
            calc_id, sale_id, rep_id, base_amount, commission_rate,
            commission_amount, bonus_amount, rule_applied, calculation_method
        ) VALUES (
            seq_commission_calc.NEXTVAL, sale_rec.sale_id, sale_rec.rep_id,
            sale_rec.unit_price * sale_rec.quantity, v_commission_rate,
            v_commission_amount, v_bonus_amount, 'TIERED_WITH_BONUS', 'AUTOMATIC'
        );
        
        -- Update sale record
        UPDATE SALE SET commission_calculated = 'Y' WHERE sale_id = sale_rec.sale_id;
    END LOOP;
    COMMIT;
END;
/

-- Insert into PAYOUT (for approved commissions)
INSERT INTO PAYOUT (payout_id, calc_id, rep_id, amount, payment_method, status, processed_by)
SELECT seq_payout.NEXTVAL, calc_id, rep_id, total_payout, 
       CASE MOD(calc_id, 3)
           WHEN 0 THEN 'DIRECT_DEPOSIT'
           WHEN 1 THEN 'CHECK'
           ELSE 'WIRE_TRANSFER'
       END,
       CASE 
           WHEN MOD(calc_id, 10) = 0 THEN 'FAILED'
           ELSE 'PROCESSED'
       END,
       'SYSTEM_AUTO'
FROM COMMISSION_CALCULATION 
WHERE status = 'APPROVED';

COMMIT;

PROMPT Data insertion completed successfully! 500+ records inserted.
-- ============================================
-- Dynamic Commission Calculator - Table Creation
-- Created by: Daniel (ID: 2796)
-- Date: November 2025
-- ============================================

-- Drop tables if they exist (for clean setup)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PAYOUT CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE COMMISSION_CALCULATION CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SALE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SALES_REP CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE COMMISSION_RULE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PRODUCT CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE REGION CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DEPARTMENT CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 1. SALES_REP Table
CREATE TABLE SALES_REP (
    rep_id NUMBER(10) CONSTRAINT pk_sales_rep PRIMARY KEY,
    first_name VARCHAR2(50) CONSTRAINT nn_rep_first_name NOT NULL,
    last_name VARCHAR2(50) CONSTRAINT nn_rep_last_name NOT NULL,
    email VARCHAR2(100) CONSTRAINT nn_rep_email NOT NULL,
    phone VARCHAR2(20),
    hire_date DATE DEFAULT SYSDATE CONSTRAINT nn_hire_date NOT NULL,
    region_id NUMBER(10),
    department_id NUMBER(10),
    base_salary NUMBER(10,2) DEFAULT 0,
    commission_rate NUMBER(5,2) DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    created_date DATE DEFAULT SYSDATE,
    modified_date DATE,
    CONSTRAINT chk_rep_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE')),
    CONSTRAINT chk_commission_rate CHECK (commission_rate BETWEEN 0 AND 100)
);

-- 2. DEPARTMENT Table
CREATE TABLE DEPARTMENT (
    dept_id NUMBER(10) CONSTRAINT pk_department PRIMARY KEY,
    dept_name VARCHAR2(100) CONSTRAINT nn_dept_name NOT NULL,
    manager_id NUMBER(10),
    budget NUMBER(15,2),
    created_date DATE DEFAULT SYSDATE
);

-- 3. REGION Table
CREATE TABLE REGION (
    region_id NUMBER(10) CONSTRAINT pk_region PRIMARY KEY,
    region_name VARCHAR2(100) CONSTRAINT nn_region_name NOT NULL,
    country VARCHAR2(50),
    manager_id NUMBER(10),
    sales_target NUMBER(15,2),
    created_date DATE DEFAULT SYSDATE
);

-- 4. PRODUCT Table
CREATE TABLE PRODUCT (
    product_id NUMBER(10) CONSTRAINT pk_product PRIMARY KEY,
    product_name VARCHAR2(200) CONSTRAINT nn_product_name NOT NULL,
    category VARCHAR2(100),
    unit_price NUMBER(10,2) CONSTRAINT nn_unit_price NOT NULL,
    cost_price NUMBER(10,2),
    commission_percentage NUMBER(5,2) DEFAULT 0,
    stock_quantity NUMBER(10) DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_product_status CHECK (status IN ('ACTIVE', 'DISCONTINUED', 'OUT_OF_STOCK')),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0)
);

-- 5. SALE Table
CREATE TABLE SALE (
    sale_id NUMBER(10) CONSTRAINT pk_sale PRIMARY KEY,
    rep_id NUMBER(10) CONSTRAINT nn_sale_rep_id NOT NULL,
    product_id NUMBER(10) CONSTRAINT nn_product_id NOT NULL,
    sale_date DATE DEFAULT SYSDATE CONSTRAINT nn_sale_date NOT NULL,
    quantity NUMBER(10) DEFAULT 1 CONSTRAINT nn_quantity NOT NULL,
    unit_price NUMBER(10,2),
    total_amount NUMBER(15,2) GENERATED ALWAYS AS (quantity * unit_price) VIRTUAL,
    customer_id VARCHAR2(50),
    invoice_number VARCHAR2(50),
    payment_method VARCHAR2(30),
    sale_status VARCHAR2(20) DEFAULT 'COMPLETED',
    commission_calculated CHAR(1) DEFAULT 'N',
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_sale_rep FOREIGN KEY (rep_id) REFERENCES SALES_REP(rep_id),
    CONSTRAINT fk_sale_product FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
    CONSTRAINT chk_sale_status CHECK (sale_status IN ('PENDING', 'COMPLETED', 'CANCELLED', 'REFUNDED')),
    CONSTRAINT chk_commission_calc CHECK (commission_calculated IN ('Y', 'N')),
    CONSTRAINT chk_quantity CHECK (quantity > 0)
);

-- 6. COMMISSION_RULE Table
CREATE TABLE COMMISSION_RULE (
    rule_id NUMBER(10) CONSTRAINT pk_commission_rule PRIMARY KEY,
    rule_name VARCHAR2(100) CONSTRAINT nn_rule_name NOT NULL,
    rule_type VARCHAR2(50) CONSTRAINT nn_rule_type NOT NULL,
    min_amount NUMBER(15,2),
    max_amount NUMBER(15,2),
    commission_rate NUMBER(5,2) CONSTRAINT nn_commission_rate NOT NULL,
    bonus_amount NUMBER(10,2) DEFAULT 0,
    effective_from DATE DEFAULT SYSDATE,
    effective_to DATE,
    priority_level NUMBER(3) DEFAULT 1,
    is_active CHAR(1) DEFAULT 'Y',
    created_by VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_rule_type CHECK (rule_type IN ('TIERED', 'FLAT_RATE', 'QUOTA_BASED', 'PRODUCT_SPECIFIC')),
    CONSTRAINT chk_is_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT chk_priority CHECK (priority_level BETWEEN 1 AND 10)
);

-- 7. COMMISSION_CALCULATION Table
CREATE TABLE COMMISSION_CALCULATION (
    calc_id NUMBER(10) CONSTRAINT pk_commission_calc PRIMARY KEY,
    sale_id NUMBER(10) CONSTRAINT nn_calc_sale_id NOT NULL,
    rep_id NUMBER(10) CONSTRAINT nn_calc_rep_id NOT NULL,
    calculation_date DATE DEFAULT SYSDATE,
    base_amount NUMBER(15,2) CONSTRAINT nn_base_amount NOT NULL,
    commission_rate NUMBER(5,2),
    commission_amount NUMBER(15,2),
    bonus_amount NUMBER(10,2) DEFAULT 0,
    total_payout NUMBER(15,2) GENERATED ALWAYS AS (commission_amount + bonus_amount) VIRTUAL,
    rule_applied VARCHAR2(100),
    calculation_method VARCHAR2(50),
    status VARCHAR2(20) DEFAULT 'CALCULATED',
    paid_date DATE,
    created_date DATE DEFAULT SYSDATE,
    modified_date DATE,
    CONSTRAINT fk_calc_sale FOREIGN KEY (sale_id) REFERENCES SALE(sale_id),
    CONSTRAINT fk_calc_rep FOREIGN KEY (rep_id) REFERENCES SALES_REP(rep_id),
    CONSTRAINT chk_calc_status CHECK (status IN ('CALCULATED', 'APPROVED', 'PAID', 'CANCELLED'))
);

-- 8. PAYOUT Table
CREATE TABLE PAYOUT (
    payout_id NUMBER(10) CONSTRAINT pk_payout PRIMARY KEY,
    calc_id NUMBER(10) CONSTRAINT nn_payout_calc_id NOT NULL,
    rep_id NUMBER(10) CONSTRAINT nn_payout_rep_id NOT NULL,
    payout_date DATE DEFAULT SYSDATE,
    amount NUMBER(15,2) CONSTRAINT nn_payout_amount NOT NULL,
    payment_method VARCHAR2(30),
    payment_reference VARCHAR2(100),
    status VARCHAR2(20) DEFAULT 'PENDING',
    processed_by VARCHAR2(100),
    processed_date DATE,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_payout_calc FOREIGN KEY (calc_id) REFERENCES COMMISSION_CALCULATION(calc_id),
    CONSTRAINT fk_payout_rep FOREIGN KEY (rep_id) REFERENCES SALES_REP(rep_id),
    CONSTRAINT chk_payout_status CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED', 'CANCELLED'))
);

-- 9. AUDIT_LOG Table (for Phase VII)
CREATE TABLE AUDIT_LOG (
    log_id NUMBER(10) CONSTRAINT pk_audit_log PRIMARY KEY,
    table_name VARCHAR2(100),
    operation_type VARCHAR2(10),
    record_id VARCHAR2(100),
    old_value CLOB,
    new_value CLOB,
    user_name VARCHAR2(100),
    ip_address VARCHAR2(50),
    log_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20),
    error_message VARCHAR2(4000)
);

-- Create Indexes for Performance
CREATE INDEX idx_sale_rep_id ON SALE(rep_id);
CREATE INDEX idx_sale_date ON SALE(sale_date);
CREATE INDEX idx_sale_product ON SALE(product_id);
CREATE INDEX idx_calc_sale ON COMMISSION_CALCULATION(sale_id);
CREATE INDEX idx_calc_rep ON COMMISSION_CALCULATION(rep_id);
CREATE INDEX idx_calc_status ON COMMISSION_CALCULATION(status);
CREATE INDEX idx_payout_rep ON PAYOUT(rep_id);
CREATE INDEX idx_payout_date ON PAYOUT(payout_date);
CREATE INDEX idx_rep_region ON SALES_REP(region_id);
CREATE INDEX idx_rep_dept ON SALES_REP(department_id);

-- Create Sequence for Primary Keys
CREATE SEQUENCE seq_sales_rep START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_department START WITH 101 INCREMENT BY 1;
CREATE SEQUENCE seq_region START WITH 201 INCREMENT BY 1;
CREATE SEQUENCE seq_product START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_sale START WITH 5001 INCREMENT BY 1;
CREATE SEQUENCE seq_commission_rule START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_commission_calc START WITH 10001 INCREMENT BY 1;
CREATE SEQUENCE seq_payout START WITH 20001 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_log START WITH 1 INCREMENT BY 1;

-- Create Comments for Documentation
COMMENT ON TABLE SALES_REP IS 'Stores sales representative information';
COMMENT ON TABLE DEPARTMENT IS 'Department information for sales reps';
COMMENT ON TABLE REGION IS 'Sales regions information';
COMMENT ON TABLE PRODUCT IS 'Product catalog with pricing';
COMMENT ON TABLE SALE IS 'Sales transactions';
COMMENT ON TABLE COMMISSION_RULE IS 'Commission calculation rules';
COMMENT ON TABLE COMMISSION_CALCULATION IS 'Calculated commission amounts';
COMMENT ON TABLE PAYOUT IS 'Commission payout records';
COMMENT ON TABLE AUDIT_LOG IS 'Audit trail for all database operations';

PROMPT All tables created successfully!
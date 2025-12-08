-- ============================================
-- HOLIDAY Table for tracking public holidays
-- ============================================
CREATE TABLE holiday (
    holiday_id NUMBER(10) CONSTRAINT pk_holiday PRIMARY KEY,
    holiday_name VARCHAR2(100) CONSTRAINT nn_holiday_name NOT NULL,
    holiday_date DATE CONSTRAINT nn_holiday_date NOT NULL,
    holiday_type VARCHAR2(50) CONSTRAINT nn_holiday_type NOT NULL,
    country VARCHAR2(50) DEFAULT 'USA',
    is_recurring CHAR(1) DEFAULT 'Y',
    created_date DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100),
    modified_date DATE,
    CONSTRAINT chk_holiday_type CHECK (holiday_type IN ('FEDERAL', 'STATE', 'COMPANY')),
    CONSTRAINT chk_is_recurring CHECK (is_recurring IN ('Y', 'N'))
);

-- Create sequence for holiday IDs
CREATE SEQUENCE seq_holiday START WITH 1 INCREMENT BY 1;

-- Create index for date-based queries
CREATE INDEX idx_holiday_date ON holiday(holiday_date);
CREATE INDEX idx_holiday_country ON holiday(country);

-- Add comments for documentation
COMMENT ON TABLE holiday IS 'Stores public holiday information for commission restriction rules';
COMMENT ON COLUMN holiday.holiday_type IS 'Type of holiday: FEDERAL, STATE, or COMPANY';
COMMENT ON COLUMN holiday.is_recurring IS 'Whether holiday repeats annually (Y/N)';

-- Insert sample holidays for the upcoming month
DECLARE
    v_next_month DATE := TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM');
    v_month_end DATE := LAST_DAY(v_next_month);
BEGIN
    -- Thanksgiving (4th Thursday of November)
    INSERT INTO holiday (holiday_id, holiday_name, holiday_date, holiday_type, created_by)
    VALUES (seq_holiday.NEXTVAL, 'Thanksgiving Day', 
            NEXT_DAY(TRUNC(v_next_month, 'MM') + 27, 'THURSDAY') - 7,
            'FEDERAL', USER);
    
    -- Day after Thanksgiving
    INSERT INTO holiday (holiday_id, holiday_name, holiday_date, holiday_type, created_by)
    VALUES (seq_holiday.NEXTVAL, 'Day after Thanksgiving', 
            NEXT_DAY(TRUNC(v_next_month, 'MM') + 27, 'THURSDAY') - 6,
            'COMPANY', USER);
    
    -- Christmas Day
    INSERT INTO holiday (holiday_id, holiday_name, holiday_date, holiday_type, created_by)
    VALUES (seq_holiday.NEXTVAL, 'Christmas Day', 
            TO_DATE(TO_CHAR(v_next_month, 'YYYY') || '-12-25', 'YYYY-MM-DD'),
            'FEDERAL', USER);
    
    -- New Year's Day (if in next month)
    IF TO_CHAR(v_next_month, 'MM') = '12' THEN
        INSERT INTO holiday (holiday_id, holiday_name, holiday_date, holiday_type, created_by)
        VALUES (seq_holiday.NEXTVAL, 'New Year''s Day', 
                TO_DATE(TO_CHAR(ADD_MONTHS(v_next_month, 1), 'YYYY') || '-01-01', 'YYYY-MM-DD'),
                'FEDERAL', USER);
    END IF;
    
    COMMIT;
END;
/

-- Verify holiday insertion
SELECT holiday_id, holiday_name, 
       TO_CHAR(holiday_date, 'YYYY-MM-DD Day') AS holiday_date,
       holiday_type, country
FROM holiday
WHERE holiday_date BETWEEN SYSDATE AND ADD_MONTHS(SYSDATE, 1)
ORDER BY holiday_date;
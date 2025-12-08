-- ============================================
-- Trigger: TRG_COMMISSION_VALIDATION
-- Purpose: Validate commission calculations before insertion
-- Business Rules:
--   1. Commission cannot exceed 50% of sale amount
--   2. Commission cannot be negative
--   3. Commission rate must match sales rep's rate
--   4. Total payout must equal commission + bonus
-- ============================================
CREATE OR REPLACE TRIGGER trg_commission_validation
BEFORE INSERT OR UPDATE ON commission_calculation
FOR EACH ROW
DECLARE
    v_sale_amount NUMBER;
    v_rep_commission_rate NUMBER;
    v_calculated_commission NUMBER;
    v_audit_log_id NUMBER;
BEGIN
    -- Get sale amount
    SELECT s.unit_price * s.quantity
    INTO v_sale_amount
    FROM sale s
    WHERE s.sale_id = :NEW.sale_id;
    
    -- Get sales rep's commission rate
    SELECT commission_rate
    INTO v_rep_commission_rate
    FROM sales_rep
    WHERE rep_id = :NEW.rep_id;
    
    -- Rule 1: Commission cannot exceed 50% of sale amount
    IF :NEW.commission_amount > v_sale_amount * 0.5 THEN
        RAISE_APPLICATION_ERROR(
            -20030,
            'Commission exceeds 50% limit of sale amount. ' ||
            'Sale Amount: $' || v_sale_amount ||
            ', Commission: $' || :NEW.commission_amount ||
            ', Limit: $' || (v_sale_amount * 0.5)
        );
    END IF;
    
    -- Rule 2: Commission cannot be negative
    IF :NEW.commission_amount < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20031,
            'Commission amount cannot be negative. ' ||
            'Commission: $' || :NEW.commission_amount
        );
    END IF;
    
    -- Rule 3: Commission should match sales rep's rate (within 1% tolerance)
    v_calculated_commission := v_sale_amount * (v_rep_commission_rate / 100);
    
    IF ABS(:NEW.commission_amount - v_calculated_commission) > v_calculated_commission * 0.01 THEN
        DBMS_OUTPUT.PUT_LINE('Warning: Commission differs from expected amount by more than 1%');
        DBMS_OUTPUT.PUT_LINE('Expected: $' || v_calculated_commission || 
                           ', Actual: $' || :NEW.commission_amount);
    END IF;
    
    -- Rule 4: Validate total payout calculation
    IF :NEW.total_payout != :NEW.commission_amount + NVL(:NEW.bonus_amount, 0) THEN
        RAISE_APPLICATION_ERROR(
            -20032,
            'Total payout miscalculation. ' ||
            'Commission: $' || :NEW.commission_amount ||
            ', Bonus: $' || NVL(:NEW.bonus_amount, 0) ||
            ', Expected Total: $' || (:NEW.commission_amount + NVL(:NEW.bonus_amount, 0)) ||
            ', Actual Total: $' || :NEW.total_payout
        );
    END IF;
    
    -- Set default values if not provided
    IF INSERTING THEN
        :NEW.calculation_date := NVL(:NEW.calculation_date, SYSDATE);
        :NEW.status := NVL(:NEW.status, 'CALCULATED');
        :NEW.created_date := SYSDATE;
    END IF;
    
    IF UPDATING THEN
        :NEW.modified_date := SYSDATE;
    END IF;
    
    -- Log commission validation
    v_audit_log_id := log_audit_event(
        'COMMISSION_CALCULATION', 
        CASE WHEN INSERTING THEN 'INSERT_VALIDATION' ELSE 'UPDATE_VALIDATION' END,
        TO_CHAR(:NEW.calc_id),
        CASE WHEN UPDATING THEN 
            TO_CLOB('Old: Amount=$' || :OLD.commission_amount || 
                    ', Status=' || :OLD.status)
        ELSE NULL END,
        TO_CLOB('New: Sale ID=' || :NEW.sale_id || 
                ', Amount=$' || :NEW.commission_amount ||
                ', Rate=' || :NEW.commission_rate || '%' ||
                ', Status=' || :NEW.status),
        'VALIDATED',
        NULL
    );
    
    DBMS_OUTPUT.PUT_LINE('Commission validation passed. Audit ID: ' || v_audit_log_id);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033, 'Sale or sales rep not found');
    WHEN OTHERS THEN
        log_audit_event(
            'COMMISSION_CALCULATION', 'VALIDATION_ERROR', 
            TO_CHAR(NVL(:NEW.calc_id, seq_commission_calc.CURRVAL)),
            NULL, NULL, 'ERROR',
            'Commission validation error: ' || SQLERRM
        );
        RAISE;
END trg_commission_validation;
/
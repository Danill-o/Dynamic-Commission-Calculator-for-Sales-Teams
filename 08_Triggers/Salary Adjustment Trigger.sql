-- ============================================
-- Trigger: TRG_SALES_REP_SALARY_ADJUST
-- Purpose: Enforce business rules when adjusting sales rep salaries
-- Business Rules:
--   1. Salary cannot be decreased by more than 10% at once
--   2. Salary cannot exceed department budget limits
--   3. All adjustments must be logged with reason
-- ============================================
CREATE OR REPLACE TRIGGER trg_sales_rep_salary_adjust
BEFORE UPDATE OF base_salary ON sales_rep
FOR EACH ROW
DECLARE
    v_department_budget NUMBER;
    v_total_salaries NUMBER;
    v_percent_change NUMBER;
    v_reason VARCHAR2(500) := 'Salary adjustment';
    v_audit_log_id NUMBER;
BEGIN
    -- Get department budget
    SELECT d.budget
    INTO v_department_budget
    FROM department d
    WHERE d.dept_id = :NEW.department_id;
    
    -- Calculate total salaries in department (including this change)
    SELECT COALESCE(SUM(
        CASE 
            WHEN rep_id = :NEW.rep_id THEN :NEW.base_salary
            ELSE base_salary
        END
    ), 0)
    INTO v_total_salaries
    FROM sales_rep
    WHERE department_id = :NEW.department_id
      AND status = 'ACTIVE';
    
    -- Rule 1: Check maximum decrease percentage
    IF :NEW.base_salary < :OLD.base_salary THEN
        v_percent_change := ((:OLD.base_salary - :NEW.base_salary) / :OLD.base_salary) * 100;
        
        IF v_percent_change > 10 THEN
            RAISE_APPLICATION_ERROR(
                -20020,
                'Salary decrease exceeds 10% limit. ' ||
                'Current: $' || :OLD.base_salary || 
                ', Proposed: $' || :NEW.base_salary ||
                ', Change: ' || ROUND(v_percent_change, 1) || '%'
            );
        END IF;
        
        v_reason := v_reason || ' (Decrease: ' || ROUND(v_percent_change, 1) || '%)';
    END IF;
    
    -- Rule 2: Check department budget
    IF v_total_salaries > v_department_budget * 0.8 THEN -- 80% of budget
        RAISE_APPLICATION_ERROR(
            -20021,
            'Salary adjustment would exceed department budget limits. ' ||
            'Department Budget: $' || v_department_budget ||
            ', Total Salaries: $' || v_total_salaries ||
            ' (80% limit: $' || (v_department_budget * 0.8) || ')'
        );
    END IF;
    
    -- Rule 3: Require modification date update
    :NEW.modified_date := SYSDATE;
    
    -- Log the salary adjustment
    v_audit_log_id := log_audit_event(
        'SALES_REP', 'SALARY_ADJUST', TO_CHAR(:NEW.rep_id),
        TO_CLOB('Old Salary: $' || :OLD.base_salary || 
                ', Commission Rate: ' || :OLD.commission_rate || '%'),
        TO_CLOB('New Salary: $' || :NEW.base_salary || 
                ', Commission Rate: ' || :NEW.commission_rate || '%' ||
                ', Reason: ' || v_reason),
        'SUCCESS',
        NULL
    );
    
    DBMS_OUTPUT.PUT_LINE('Salary adjustment logged with Audit ID: ' || v_audit_log_id);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20022, 'Department not found for sales rep');
    WHEN OTHERS THEN
        log_audit_event(
            'SALES_REP', 'TRIGGER_ERROR', 'SALARY_ADJUST',
            TO_CHAR(:OLD.rep_id), NULL, 'ERROR',
            'Salary adjustment error: ' || SQLERRM
        );
        RAISE;
END trg_sales_rep_salary_adjust;
/
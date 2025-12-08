-- ============================================
-- Compound Trigger: TRG_SALE_COMPOUND
-- Purpose: Comprehensive DML restriction and auditing for SALE table
-- Features:
--   1. Before statement restriction checks
--   2. Row-level auditing for each DML operation
--   3. After statement summary logging
--   4. Exception handling at each level
-- ============================================
CREATE OR REPLACE TRIGGER trg_sale_compound
FOR INSERT OR UPDATE OR DELETE ON sale
COMPOUND TRIGGER

    -- Global declarations
    TYPE t_row_data IS RECORD (
        sale_id sale.sale_id%TYPE,
        rep_id sale.rep_id%TYPE,
        old_status sale.sale_status%TYPE,
        new_status sale.sale_status%TYPE
    );
    
    TYPE t_row_table IS TABLE OF t_row_data INDEX BY PLS_INTEGER;
    g_row_data t_row_table;
    
    g_operation_type VARCHAR2(10);
    g_employee_id VARCHAR2(100) := USER;
    g_current_date DATE := SYSDATE;
    g_is_allowed BOOLEAN := TRUE;
    g_rows_affected NUMBER := 0;
    g_audit_log_ids SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
    
    -- Utility function to get operation type
    FUNCTION get_operation_type RETURN VARCHAR2 IS
    BEGIN
        IF INSERTING THEN RETURN 'INSERT'; 
        ELSIF UPDATING THEN RETURN 'UPDATE';
        ELSIF DELETING THEN RETURN 'DELETE';
        ELSE RETURN 'UNKNOWN';
        END IF;
    END get_operation_type;
    
    -- Before Statement Section
    BEFORE STATEMENT IS
    BEGIN
        g_operation_type := get_operation_type();
        
        -- Check DML restriction
        g_is_allowed := can_employee_perform_dml(
            p_employee_id => g_employee_id,
            p_operation_type => g_operation_type,
            p_check_date => g_current_date
        );
        
        IF NOT g_is_allowed THEN
            RAISE_APPLICATION_ERROR(
                -20010,
                'COMPOUND TRIGGER: ' || g_operation_type || 
                ' operations on SALE table are RESTRICTED on ' ||
                TO_CHAR(g_current_date, 'Day, YYYY-MM-DD') ||
                '. Weekdays and holidays are not allowed for DML operations.'
            );
        END IF;
        
        -- Log statement start
        g_audit_log_ids.EXTEND;
        g_audit_log_ids(g_audit_log_ids.LAST) := log_audit_event(
            'SALE', 'BEFORE_STATEMENT', g_operation_type,
            NULL,
            TO_CLOB('Employee: ' || g_employee_id || 
                    ', Time: ' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF3')),
            'STARTED',
            NULL
        );
        
    EXCEPTION
        WHEN OTHERS THEN
            log_audit_event(
                'SALE', 'TRIGGER_ERROR', 'BEFORE_STATEMENT',
                NULL, NULL, 'ERROR',
                'Before statement error: ' || SQLERRM
            );
            RAISE;
    END BEFORE STATEMENT;
    
    -- Before Each Row Section
    BEFORE EACH ROW IS
    BEGIN
        -- Store row data for auditing
        IF INSERTING OR UPDATING THEN
            g_row_data(g_row_data.COUNT + 1).sale_id := :NEW.sale_id;
            g_row_data(g_row_data.COUNT).rep_id := :NEW.rep_id;
            
            IF INSERTING THEN
                g_row_data(g_row_data.COUNT).old_status := NULL;
                g_row_data(g_row_data.COUNT).new_status := :NEW.sale_status;
            ELSIF UPDATING THEN
                g_row_data(g_row_data.COUNT).old_status := :OLD.sale_status;
                g_row_data(g_row_data.COUNT).new_status := :NEW.sale_status;
            END IF;
            
            -- Additional business rule: Cannot modify completed sales
            IF UPDATING AND :OLD.sale_status = 'COMPLETED' THEN
                RAISE_APPLICATION_ERROR(
                    -20011,
                    'Cannot modify completed sale (ID: ' || :OLD.sale_id || ')'
                );
            END IF;
            
        ELSIF DELETING THEN
            g_row_data(g_row_data.COUNT + 1).sale_id := :OLD.sale_id;
            g_row_data(g_row_data.COUNT).rep_id := :OLD.rep_id;
            g_row_data(g_row_data.COUNT).old_status := :OLD.sale_status;
            g_row_data(g_row_data.COUNT).new_status := NULL;
            
            -- Business rule: Cannot delete completed sales
            IF :OLD.sale_status = 'COMPLETED' THEN
                RAISE_APPLICATION_ERROR(
                    -20012,
                    'Cannot delete completed sale (ID: ' || :OLD.sale_id || ')'
                );
            END IF;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            log_audit_event(
                'SALE', 'TRIGGER_ERROR', 'BEFORE_ROW',
                TO_CHAR(:OLD.sale_id), NULL, 'ERROR',
                'Before row error: ' || SQLERRM
            );
            RAISE;
    END BEFORE EACH ROW;
    
    -- After Each Row Section
    AFTER EACH ROW IS
        v_audit_log_id NUMBER;
    BEGIN
        -- Log individual row operation
        v_audit_log_id := log_audit_event(
            'SALE', g_operation_type || '_ROW',
            TO_CHAR(NVL(:NEW.sale_id, :OLD.sale_id)),
            TO_CLOB(
                CASE 
                    WHEN UPDATING OR DELETING THEN
                        'Old: Rep=' || :OLD.rep_id || 
                        ', Status=' || :OLD.sale_status ||
                        ', Amount=' || TO_CHAR(:OLD.unit_price * :OLD.quantity, '999,999.99')
                    ELSE NULL
                END
            ),
            TO_CLOB(
                CASE 
                    WHEN INSERTING OR UPDATING THEN
                        'New: Rep=' || :NEW.rep_id || 
                        ', Status=' || :NEW.sale_status ||
                        ', Amount=' || TO_CHAR(:NEW.unit_price * :NEW.quantity, '999,999.99')
                    ELSE 'DELETED'
                END
            ),
            'SUCCESS',
            NULL
        );
        
        g_rows_affected := g_rows_affected + 1;
        g_audit_log_ids.EXTEND;
        g_audit_log_ids(g_audit_log_ids.LAST) := v_audit_log_id;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Continue processing other rows even if audit fails
            NULL;
    END AFTER EACH ROW;
    
    -- After Statement Section
    AFTER STATEMENT IS
        v_summary CLOB;
    BEGIN
        -- Build operation summary
        v_summary := TO_CLOB(
            'Operation: ' || g_operation_type || CHR(10) ||
            'Employee: ' || g_employee_id || CHR(10) ||
            'Date/Time: ' || TO_CHAR(g_current_date, 'YYYY-MM-DD HH24:MI:SS') || CHR(10) ||
            'Rows Affected: ' || g_rows_affected || CHR(10) ||
            'Weekday Check: ' || CASE WHEN is_weekday(g_current_date) THEN 'Weekday' ELSE 'Weekend' END || CHR(10) ||
            'Holiday Check: ' || CASE WHEN is_holiday(g_current_date) THEN 'Holiday' ELSE 'Not Holiday' END
        );
        
        -- Log statement completion
        log_audit_event(
            'SALE', 'AFTER_STATEMENT', g_operation_type,
            NULL,
            v_summary,
            'COMPLETED',
            NULL
        );
        
        -- Reset global variables for next statement
        g_row_data.DELETE;
        g_rows_affected := 0;
        g_audit_log_ids.DELETE;
        
    EXCEPTION
        WHEN OTHERS THEN
            log_audit_event(
                'SALE', 'TRIGGER_ERROR', 'AFTER_STATEMENT',
                NULL, NULL, 'ERROR',
                'After statement error: ' || SQLERRM
            );
            -- Don't re-raise, as main operation succeeded
    END AFTER STATEMENT;
    
END trg_sale_compound;
/
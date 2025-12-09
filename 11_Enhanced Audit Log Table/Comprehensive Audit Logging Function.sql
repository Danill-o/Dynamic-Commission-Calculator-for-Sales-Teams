-- ============================================
-- Function: LOG_AUDIT_EVENT
-- Purpose: Log all audit events with comprehensive details
-- Parameters:
--   p_table_name - Table being modified
--   p_operation_type - Operation type (INSERT/UPDATE/DELETE)
--   p_record_id - Record identifier
--   p_old_values - Old values (JSON format)
--   p_new_values - New values (JSON format)
--   p_status - Operation status
--   p_error_message - Error message if failed
-- Returns: Audit log ID
-- ============================================


CREATE OR REPLACE FUNCTION log_audit_event(
    p_table_name IN VARCHAR2,
    p_operation_type IN VARCHAR2,
    p_record_id IN VARCHAR2,
    p_old_values IN CLOB DEFAULT NULL,
    p_new_values IN CLOB DEFAULT NULL,
    p_status IN VARCHAR2 DEFAULT 'SUCCESS',
    p_error_message IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION; -- Ensure audit log is saved even if main transaction rolls back
    v_log_id NUMBER;
    v_session_id VARCHAR2(100);
    v_machine_name VARCHAR2(100);
    v_os_user VARCHAR2(100);
    v_module_name VARCHAR2(100);
    v_action_name VARCHAR2(100);
    v_client_identifier VARCHAR2(100);
BEGIN
    -- Get session information
    BEGIN
        SELECT sid INTO v_session_id FROM v$mystat WHERE rownum = 1;
    EXCEPTION
        WHEN OTHERS THEN v_session_id := 'N/A';
    END;
    
    -- Get client information
    v_machine_name := SYS_CONTEXT('USERENV', 'HOST');
    v_os_user := SYS_CONTEXT('USERENV', 'OS_USER');
    v_module_name := SYS_CONTEXT('USERENV', 'MODULE');
    v_action_name := SYS_CONTEXT('USERENV', 'ACTION');
    v_client_identifier := SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER');
    
    -- Generate new log ID
    SELECT seq_audit_log.NEXTVAL INTO v_log_id FROM dual;
    
    -- Insert audit record
    INSERT INTO audit_log (
        log_id, table_name, operation_type, record_id,
        old_value, new_value, user_name, ip_address,
        log_timestamp, status, error_message,
        session_id, machine_name, os_user,
        module_name, action_name, client_identifier
    ) VALUES (
        v_log_id, p_table_name, p_operation_type, p_record_id,
        p_old_values, p_new_values, USER,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'), SYSTIMESTAMP,
        p_status, p_error_message, v_session_id,
        v_machine_name, v_os_user, v_module_name,
        v_action_name, v_client_identifier
    );
    
    COMMIT;
    RETURN v_log_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Try to log the audit logging error (meta-audit)
        BEGIN
            INSERT INTO audit_log (
                log_id, table_name, operation_type,
                user_name, log_timestamp, status, error_message
            ) VALUES (
                seq_audit_log.NEXTVAL, 'AUDIT_LOG', 'ERROR',
                USER, SYSTIMESTAMP, 'FAILED',
                'Failed to log audit event: ' || SQLERRM
            );
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN NULL; -- Last resort: do nothing
        END;
        RETURN -1; -- Return error code
END log_audit_event;
/

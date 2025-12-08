-- ============================================
-- Enhance existing AUDIT_LOG table for Phase VII
-- ============================================
-- Note: AUDIT_LOG table already created in Phase V, adding missing columns

ALTER TABLE audit_log ADD (
    session_id VARCHAR2(100),
    machine_name VARCHAR2(100),
    os_user VARCHAR2(100),
    module_name VARCHAR2(100),
    action_name VARCHAR2(100),
    client_identifier VARCHAR2(100),
    execution_time NUMBER(10,6)
);

-- Add comments for new columns
COMMENT ON COLUMN audit_log.session_id IS 'Oracle session identifier';
COMMENT ON COLUMN audit_log.machine_name IS 'Client machine name';
COMMENT ON COLUMN audit_log.os_user IS 'Operating system username';
COMMENT ON COLUMN audit_log.module_name IS 'Application module name';
COMMENT ON COLUMN audit_log.action_name IS 'Application action name';
COMMENT ON COLUMN audit_log.client_identifier IS 'Client identifier';
COMMENT ON COLUMN audit_log.execution_time IS 'Execution time in seconds';

-- Create indexes for audit queries
CREATE INDEX idx_audit_timestamp ON audit_log(log_timestamp);
CREATE INDEX idx_audit_operation ON audit_log(operation_type);
CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_user ON audit_log(user_name);
CREATE INDEX idx_audit_status ON audit_log(status);

-- Create a view for easy audit reporting
CREATE OR REPLACE VIEW vw_audit_report AS
SELECT 
    log_id,
    table_name,
    operation_type,
    record_id,
    user_name,
    TO_CHAR(log_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS timestamp,
    status,
    error_message,
    session_id,
    machine_name,
    os_user,
    module_name,
    execution_time
FROM audit_log
ORDER BY log_timestamp DESC;
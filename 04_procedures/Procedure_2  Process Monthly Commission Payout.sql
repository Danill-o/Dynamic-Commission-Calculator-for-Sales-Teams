-- ============================================
-- Procedure: PROCESS_MONTHLY_PAYOUT
-- Purpose: Process commission payouts for a given month
-- Parameters:
--   p_month IN - Month in 'YYYY-MM' format
--   p_payment_method IN - Payment method
--   p_total_payout OUT - Total amount paid out
--   p_records_processed OUT - Number of records processed
-- ============================================
CREATE OR REPLACE PROCEDURE process_monthly_payout(
    p_month IN VARCHAR2,
    p_payment_method IN VARCHAR2 DEFAULT 'DIRECT_DEPOSIT',
    p_total_payout OUT NUMBER,
    p_records_processed OUT NUMBER
)
IS
    CURSOR c_commissions IS
        SELECT cc.calc_id, cc.rep_id, cc.total_payout
        FROM commission_calculation cc
        WHERE cc.status = 'CALCULATED'
          AND TO_CHAR(cc.calculation_date, 'YYYY-MM') = p_month
          AND cc.total_payout > 0
        FOR UPDATE;
        
    v_payout_id NUMBER;
    v_success_count NUMBER := 0;
    v_failed_count NUMBER := 0;
    v_total_amount NUMBER := 0;
    
    -- Custom exceptions
    invalid_month_format EXCEPTION;
    no_commissions_found EXCEPTION;
    
BEGIN
    -- Initialize outputs
    p_total_payout := 0;
    p_records_processed := 0;
    
    -- Validate month format
    IF LENGTH(p_month) != 7 OR SUBSTR(p_month, 5, 1) != '-' THEN
        RAISE invalid_month_format;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Starting monthly payout process for ' || p_month);
    DBMS_OUTPUT.PUT_LINE('Payment Method: ' || p_payment_method);
    
    -- Process each commission
    FOR commission_rec IN c_commissions LOOP
        BEGIN
            -- Generate payout ID
            SELECT seq_payout.NEXTVAL INTO v_payout_id FROM dual;
            
            -- Create payout record
            INSERT INTO payout (
                payout_id, calc_id, rep_id, amount,
                payment_method, status, processed_by,
                processed_date
            ) VALUES (
                v_payout_id, commission_rec.calc_id,
                commission_rec.rep_id, commission_rec.total_payout,
                p_payment_method, 'PROCESSED', USER,
                SYSDATE
            );
            
            -- Update commission status
            UPDATE commission_calculation
            SET status = 'PAID',
                paid_date = SYSDATE,
                modified_date = SYSDATE
            WHERE calc_id = commission_rec.calc_id;
            
            -- Update totals
            v_total_amount := v_total_amount + commission_rec.total_payout;
            v_success_count := v_success_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('  Processed: Calc ID ' || commission_rec.calc_id || 
                                ' - $' || ROUND(commission_rec.total_payout, 2));
            
        EXCEPTION
            WHEN OTHERS THEN
                v_failed_count := v_failed_count + 1;
                DBMS_OUTPUT.PUT_LINE('  FAILED: Calc ID ' || commission_rec.calc_id || 
                                    ' - Error: ' || SQLERRM);
        END;
    END LOOP;
    
    -- Check if any records were processed
    IF v_success_count = 0 THEN
        RAISE no_commissions_found;
    END IF;
    
    -- Set output parameters
    p_total_payout := v_total_amount;
    p_records_processed := v_success_count;
    
    COMMIT;
    
    -- Print summary
    DBMS_OUTPUT.PUT_LINE('===================================');
    DBMS_OUTPUT.PUT_LINE('PAYOUT PROCESSING COMPLETE');
    DBMS_OUTPUT.PUT_LINE('Month: ' || p_month);
    DBMS_OUTPUT.PUT_LINE('Successfully processed: ' || v_success_count || ' records');
    DBMS_OUTPUT.PUT_LINE('Failed: ' || v_failed_count || ' records');
    DBMS_OUTPUT.PUT_LINE('Total amount paid: $' || ROUND(v_total_amount, 2));
    DBMS_OUTPUT.PUT_LINE('===================================');
    
EXCEPTION
    WHEN invalid_month_format THEN
        p_total_payout := 0;
        p_records_processed := 0;
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid month format. Use ''YYYY-MM''');
        ROLLBACK;
        
    WHEN no_commissions_found THEN
        p_total_payout := 0;
        p_records_processed := 0;
        DBMS_OUTPUT.PUT_LINE('ERROR: No commissions found for month ' || p_month);
        ROLLBACK;
        
    WHEN OTHERS THEN
        p_total_payout := 0;
        p_records_processed := 0;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
        
END process_monthly_payout;
/
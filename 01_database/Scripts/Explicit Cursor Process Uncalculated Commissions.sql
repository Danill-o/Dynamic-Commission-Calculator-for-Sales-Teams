-- ============================================
-- Explicit Cursor Example
-- Purpose: Process commissions for sales that haven't been calculated
-- ============================================
DECLARE
    -- Declare explicit cursor
    CURSOR c_uncalculated_sales IS
        SELECT s.sale_id, s.rep_id, 
               s.unit_price * s.quantity AS sale_amount,
               sr.commission_rate,
               p.commission_percentage
        FROM sale s
        JOIN sales_rep sr ON s.rep_id = sr.rep_id
        JOIN product p ON s.product_id = p.product_id
        WHERE s.commission_calculated = 'N'
          AND s.sale_status = 'COMPLETED'
        ORDER BY s.sale_date;
    
    -- Record type for cursor
    TYPE sales_rec_type IS RECORD (
        sale_id sale.sale_id%TYPE,
        rep_id sale.rep_id%TYPE,
        sale_amount NUMBER,
        commission_rate sales_rep.commission_rate%TYPE,
        product_commission product.commission_percentage%TYPE
    );
    
    v_sales_rec sales_rec_type;
    v_total_commission NUMBER := 0;
    v_records_processed NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('Processing uncalculated commissions...');
    DBMS_OUTPUT.PUT_LINE('===================================');
    
    -- Open cursor
    OPEN c_uncalculated_sales;
    
    LOOP
        -- Fetch row
        FETCH c_uncalculated_sales INTO v_sales_rec;
        EXIT WHEN c_uncalculated_sales%NOTFOUND;
        
        -- Calculate commission
        DECLARE
            v_commission_amount NUMBER;
        BEGIN
            -- Base commission from rep rate
            v_commission_amount := v_sales_rec.sale_amount * 
                                  (v_sales_rec.commission_rate / 100);
            
            -- Add product-specific commission
            v_commission_amount := v_commission_amount + 
                                  (v_sales_rec.sale_amount * 
                                   (v_sales_rec.product_commission / 100));
            
            -- Insert commission calculation
            INSERT INTO commission_calculation (
                calc_id, sale_id, rep_id, base_amount,
                commission_rate, commission_amount, rule_applied,
                calculation_method
            ) VALUES (
                seq_commission_calc.NEXTVAL, v_sales_rec.sale_id,
                v_sales_rec.rep_id, v_sales_rec.sale_amount,
                v_sales_rec.commission_rate, v_commission_amount,
                'CURSOR_PROCESSING', 'BATCH'
            );
            
            -- Update sale record
            UPDATE sale
            SET commission_calculated = 'Y'
            WHERE sale_id = v_sales_rec.sale_id;
            
            -- Update totals
            v_total_commission := v_total_commission + v_commission_amount;
            v_records_processed := v_records_processed + 1;
            
            -- Print every 10th record
            IF MOD(v_records_processed, 10) = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Processed ' || v_records_processed || ' records...');
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error processing sale ' || v_sales_rec.sale_id || 
                                    ': ' || SQLERRM);
        END;
    END LOOP;
    
    -- Close cursor
    CLOSE c_uncalculated_sales;
    
    COMMIT;
    
    -- Print summary
    DBMS_OUTPUT.PUT_LINE('===================================');
    DBMS_OUTPUT.PUT_LINE('PROCESSING COMPLETE');
    DBMS_OUTPUT.PUT_LINE('Records processed: ' || v_records_processed);
    DBMS_OUTPUT.PUT_LINE('Total commission: $' || ROUND(v_total_commission, 2));
    DBMS_OUTPUT.PUT_LINE('===================================');
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_uncalculated_sales%ISOPEN THEN
            CLOSE c_uncalculated_sales;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        ROLLBACK;
END;
/
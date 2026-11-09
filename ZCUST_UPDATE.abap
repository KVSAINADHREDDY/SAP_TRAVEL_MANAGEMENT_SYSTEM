REPORT zcust_update.
 
TABLES: zcustomer_table.
 
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  p_custid TYPE zcustomer_table-customer_id OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
 
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
  p_name   TYPE zcustomer_table-cust_name,
  p_mobile TYPE zcustomer_table-mobile,
  p_email  TYPE zcustomer_table-email,
  p_addr   TYPE zcustomer_table-address.
SELECTION-SCREEN END OF BLOCK b2.
 
START-OF-SELECTION.
 
  DATA: ls_customer TYPE zcustomer_table.
 
  SELECT SINGLE *
    FROM zcustomer_table
    INTO ls_customer
    WHERE customer_id = p_custid.
 
  IF sy-subrc <> 0.
    MESSAGE 'Customer not found.' TYPE 'E'.
  ELSE.
    " Only overwrite fields the user actually entered
    IF p_name   IS NOT INITIAL. ls_customer-cust_name = p_name.   ENDIF.
    IF p_mobile IS NOT INITIAL. ls_customer-mobile    = p_mobile. ENDIF.
    IF p_email  IS NOT INITIAL. ls_customer-email     = p_email.  ENDIF.
    IF p_addr   IS NOT INITIAL. ls_customer-address   = p_addr.   ENDIF.
 
    UPDATE zcustomer_table FROM ls_customer.
 
    IF sy-subrc = 0.
      WRITE: / 'Customer updated successfully:', p_custid.
    ELSE.
      WRITE: / 'Error updating customer.'.
    ENDIF.
  ENDIF.
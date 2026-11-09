REPORT zcust_create.
 
TABLES: zcustomer_table.
 
PARAMETERS:
  p_custid TYPE zcustomer_table-customer_id OBLIGATORY,
  p_name   TYPE zcustomer_table-cust_name   OBLIGATORY,
  p_mobile TYPE zcustomer_table-mobile,
  p_email  TYPE zcustomer_table-email,
  p_addr   TYPE zcustomer_table-address,
  p_pass   TYPE zcustomer_table-passport_no,
  p_nation TYPE zcustomer_table-nationality.
 
START-OF-SELECTION.
 
  DATA: ls_customer TYPE zcustomer_table.
 
  " Duplicate check
  SELECT SINGLE *
    FROM zcustomer_table
    INTO ls_customer
    WHERE customer_id = p_custid.
 
  IF sy-subrc = 0.
    MESSAGE 'Customer ID already exists.' TYPE 'E'.
  ELSE.
    CLEAR ls_customer.
    ls_customer-customer_id = p_custid.
    ls_customer-cust_name   = p_name.
    ls_customer-mobile      = p_mobile.
    ls_customer-email       = p_email.
    ls_customer-address     = p_addr.
    ls_customer-passport_no = p_pass.
    ls_customer-nationality = p_nation.
 
    INSERT zcustomer_table FROM ls_customer.
 
    IF sy-subrc = 0.
      WRITE: / 'Customer created successfully:', p_custid.
    ELSE.
      WRITE: / 'Error creating customer. Please try again.'.
    ENDIF.
  ENDIF.
REPORT zcust_delete.
 
TABLES: zcustomer_table.
 
PARAMETERS:
  p_custid TYPE zcustomer_table-customer_id OBLIGATORY.
 
START-OF-SELECTION.
 
  DATA: ls_customer TYPE zcustomer_table.
 
  SELECT SINGLE *
    FROM zcustomer_table
    INTO ls_customer
    WHERE customer_id = p_custid.
 
  IF sy-subrc <> 0.
    MESSAGE 'Customer not found.' TYPE 'E'.
  ELSE.
    DELETE zcustomer_table FROM ls_customer.
 
    IF sy-subrc = 0.
      WRITE: / 'Customer deleted successfully:', p_custid.
    ELSE.
      WRITE: / 'Error deleting customer.'.
    ENDIF.
  ENDIF.
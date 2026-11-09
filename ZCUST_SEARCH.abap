REPORT zcust_search.
 
TABLES: zcustomer_table.
 
SELECT-OPTIONS:
  s_custid FOR zcustomer_table-customer_id,
  s_name   FOR zcustomer_table-cust_name,
  s_mobile FOR zcustomer_table-mobile.
 
DATA: gt_customer TYPE TABLE OF zcustomer_table.
 
START-OF-SELECTION.
 
  SELECT *
    FROM zcustomer_table
    INTO TABLE gt_customer
    WHERE customer_id IN s_custid
      AND cust_name   IN s_name
      AND mobile      IN s_mobile.
 
  IF sy-subrc <> 0.
    MESSAGE 'No customers found for the given criteria.' TYPE 'I'.
  ELSE.
    DATA: lo_alv TYPE REF TO cl_salv_table.
 
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lo_alv
          CHANGING
            t_table      = gt_customer ).
 
        lo_alv->get_functions( )->set_all( abap_true ).
        lo_alv->get_columns( )->set_optimize( abap_true ).
        lo_alv->display( ).
 
      CATCH cx_salv_msg INTO DATA(lx_msg).
        MESSAGE lx_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDIF.
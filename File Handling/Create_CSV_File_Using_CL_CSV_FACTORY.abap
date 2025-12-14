SELECT FROM vbak
       FIELDS vbeln, vbtyp, erdat
       INTO TABLE @DATA(lt_test)
       UP TO 10 ROWS.

"Simple CSV generation with header:
DATA(lv_xstring_v1) = cl_csv_factory=>new_writer(
                       )->set_delimiter( ';'
                       )->set_write_header( abap_true
                       )->write( REF #( lt_test ) ).

"CSV generation with custom headers and field formatting:
DATA(lv_xstring_v2) = cl_csv_factory=>new_writer(
                       )->set_delimiter( ';'
                       )->set_write_header( abap_true
                       )->write(
                         itab_ref = REF #( lt_test )
                         fieldcatalog = VALUE if_csv_field_catalog=>ty_t_fieldcatalog(
                           ( fieldname = 'VBELN' header_text = |Sales Order| )
                           ( fieldname = 'VBTYP' header_text = |Sales Document Type| )
                           ( fieldname = 'ERDAT' header_text = |Created On| format = cl_csv_field_format=>date_iso ) ) ).

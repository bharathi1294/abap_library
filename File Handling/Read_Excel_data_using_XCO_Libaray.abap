DATA: lv_rc TYPE i.
DATA: lt_files TYPE filetable.
DATA: lv_action TYPE i.
DATA: lt_bin_data TYPE w3mimetabtype.

PARAMETERS: p_file TYPE ibipparms-path OBLIGATORY.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  cl_gui_frontend_services=>file_open_dialog( EXPORTING file_filter = |xlsx (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|
                                              CHANGING  file_table  = lt_files
                                                        rc          = lv_rc
                                                        user_action = lv_action ).

  p_file = |{ lt_files[ 1 ]-filename }|.
START-OF-SELECTION.
* Excel upload
  cl_gui_frontend_services=>gui_upload( EXPORTING filename   = CONV #( p_file )
                                                  filetype   = 'BIN'
                                        IMPORTING filelength = DATA(lv_filesize)
                                        CHANGING  data_tab   = lt_bin_data ).

* Convert Binary Data to XSTRING - We can use CL_BCS_CONVERT to convert the binary data to XSTRING
  DATA(lv_excel_data) = cl_bcs_convert=>solix_to_xstring( it_solix = lt_bin_data ).

* Get the read access to the Excel file using XCO Library
  DATA(lo_xl) = xco_cp_xlsx=>document->for_file_content( lv_excel_data )->read_access( ).

* Read the Excel file
*-> Reading the first sheet
  DATA(lo_sheet_by_position) = lo_xl->get_workbook( )->worksheet->at_position( 1 ).
*-> Reading using Sheet name
  DATA(lo_sheet_by_name) = lo_xl->get_workbook( )->worksheet->for_name( 'Employees' ).

  IF NOT lo_sheet_by_position->exists( ).
    RETURN. "Sheet does not exist
  ENDIF.

* Read all data from the sheet
  DATA(lo_sel_pattern_all) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

* Read data from specific rows and columns
*-> From column(A) to column(C)
  DATA(lo_sel_pattern_col) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( 
                                                                     )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                                                                     )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'C' )
                                                                     )->get_pattern( ).
*-> From row(2) to row(5)
  DATA(lo_sel_pattern_row) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( 
                                                                     )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
                                                                     )->to_row( xco_cp_xlsx=>coordinate->for_numeric_value( 5 )
                                                                     )->get_pattern( ).
*-> Both Row and Column
  DATA(lo_sel_pattern_both) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( 
                                                                     )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
                                                                     )->to_row( xco_cp_xlsx=>coordinate->for_numeric_value( 5 )
                                                                     )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                                                                     )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'C' )
                                                                     )->get_pattern( ).

  TYPES: BEGIN OF ty_employee,
           employee_id   TYPE string,
           employee_name TYPE string,
           mobile_number TYPE string,
           date_of_birth TYPE string,
         END OF ty_employee.
  DATA: lt_employees TYPE TABLE OF ty_employee WITH EMPTY KEY.

* Fill the internal table by using the selection patterns
  DATA(o_result) = lo_sheet_by_position->select( lo_sel_pattern_all " lo_sel_pattern_col, lo_sel_pattern_row, (lo_sel_pattern_both
                                    )->row_stream(
                                    )->operation->write_to( REF #( lt_employees )
                                    )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
                                    )->execute( ).

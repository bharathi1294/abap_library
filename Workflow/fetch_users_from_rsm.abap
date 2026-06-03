CLASS lcl_rsm DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS get_users_from_rsm
      IMPORTING
        iv_team_category TYPE rsm_de_team_category
        iv_function      TYPE rsm_de_function
        it_attributes    TYPE atmtg_name_value_pair_tab
      EXPORTING
        et_agents        TYPE rsm_tt_user .
ENDCLASS.
CLASS lcl_rsm IMPLEMENTATION.
  METHOD get_users_from_rsm.
    DATA(lo_determine_responsible) = NEW cl_rsm_determine_responsible( ).
    DATA(lt_functions) = VALUE rsm_tt_functions( ( iv_function ) ).
    DATA(lt_parameters) = VALUE rsmtg_name_value_pair_tab( ( name = 'RESPYMGMTTEAMCATEGORY'         value = REF #( iv_team_category ) )
                                                           ( name = 'RESPYMGMTFUNCTION'             value = REF #( lt_functions ) )
                                                           ( name = 'RESPYMGMTATTRIBUTENAMEVALPAIR' value = REF #( it_attributes ) ) ).
    TRY.
        CALL METHOD lo_determine_responsible->if_rsm_determine_responsible~determine_responsible
          EXPORTING
            iv_rule_id                    = 'RESPY_MGMT_TEAMS'
            it_parameters_name_value_pair = lt_parameters
          IMPORTING
            et_agents                     = et_agents.
      CATCH cx_rsm_runtime_error INTO DATA(lr_runtime_error).
      CATCH cx_rsm_no_agent_determined INTO DATA(lr_no_agents).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

"------------------------------------------------
 DATA(lt_bill_to_party) = VALUE string_table( ( `0000000001` ) ( `0000000002` ) ).
 DATA(lv_sales_org) = `0001`.
 lcl_rsm=>get_users_from_rsm(
    EXPORTING
      " Team Category maintained in Responsibility Management
      iv_team_category = 'SALES'

      " Function for which users should be determined
      " Example:
      " CMR1LVLA - Level 1 Approver
      " CMR2LVLA - Level 2 Approver
      " CMR3LVLA - Level 3 Approver
      iv_function      = 'CMR1LVLA'

      " Responsibility Definition values
      it_attributes    = VALUE atmtg_name_value_pair_tab(
                           ( name  = 'BILL_TO_PARTY'
                             kind  = 'T' "Table
                             value = REF #( lt_bill_to_party ) )
                           ( name  = 'SALES_ORG'
                             kind  = 'E' "Single Value
                             value = REF #( lv_sales_org ) ) )
    IMPORTING
      et_agents        = DATA(lt_users) ).

  " Technical names of Responsibility Attributes can be found in table P_RESPYMGMTATTRIBUTEDETAILS.

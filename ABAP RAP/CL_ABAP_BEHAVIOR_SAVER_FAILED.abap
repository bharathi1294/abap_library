"The usage of CL_ABAP_BEHAVIOR_SAVER_FAILED

"Inheriting from cl_abap_behavior_saver
CLASS lsc_class DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_class IMPLEMENTATION.
  METHOD save_modified.
    LOOP AT update-entity_name ASSIGNING FIELD-SYMBOL(<fs>).
      "calling bapi and returns some error
      reported-entity_name = VALUE #( BASE reported-entity_name ( %key = <fs>-%key
                                                                  %msg = new_message_with_text(
                                                                          severity = if_abap_behv_message=>severity-error
                                                                          text     = 'some error'  ) ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

"Inheriting from cl_abap_behavior_saver_failed
CLASS lsc_class DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_class IMPLEMENTATION.
  METHOD save_modified.
    LOOP AT update-entity_name ASSIGNING FIELD-SYMBOL(<fs>).
      "calling bapi and returns some error
      failed-entity_name = VALUE #( BASE failed-entity_name ( %key = <fs>-%key ) ).
      reported-entity_name = VALUE #( BASE reported-entity_name ( %key = <fs>-%key
                                                                  %msg = new_message_with_text(
                                                                          severity = if_abap_behv_message=>severity-error
                                                                          text     = 'some error'  ) ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

"More Info - https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENABP_CL_ABAP_BEH_SAVER_FAILED.html
" - https://www.linkedin.com/feed/update/urn:li:activity:7427720577400033280/

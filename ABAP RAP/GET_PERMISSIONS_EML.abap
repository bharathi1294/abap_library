GET PERMISSIONS ONLY INSTANCE FEATURES OF /DMO/FSA_R_RootTP
ENTITY root
FROM VALUE #( ( id = '19BBB21A28891EEFA1E7D02ABF662AA2' ) )
REQUEST VALUE #( %update = if_abap_behv=>mk-on
                 %delete = if_abap_behv=>mk-on
                 %field = VALUE #( id = if_abap_behv=>mk-on )
                 %action = VALUE #( edit = if_abap_behv=>mk-on ) )
RESULT DATA(ls_result)
REPORTED DATA(ls_reported)
FAILED DATA(ls_failed).

ASSIGN ls_result-instances[ KEY entity id = '19BBB21A28891EEFA1E7D02ABF662AA2' ] TO FIELD-SYMBOL(<feature_instance>).
IF <feature_instance> IS NOT ASSIGNED.
  RETURN.
ENDIF.
IF <feature_instance>-%update = if_abap_behv=>fc-o-enabled AND <feature_instance>-%action-edit = if_abap_behv=>fc-o-enabled .
  """"
ENDIF.
IF <feature_instance>-%field-id = if_abap_behv=>fc-f-read_only.
  """"
ENDIF.

"GET PERMISSIONS ONLY INSTANCE AUTHORIZATION OF .....
"GET PERMISSIONS ONLY INSTANCE OF ....
"GET PERMISSIONS ONLY GLOBAL FEATURES OF ....
"GET PERMISSIONS ONLY GLOBAL AUTHORIZATION OF ....
"GET PERMISSIONS ONLY GLOBAL OF ....

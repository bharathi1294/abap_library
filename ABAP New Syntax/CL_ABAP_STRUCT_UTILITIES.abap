TYPES: BEGIN OF ty_user,
         user_id1 TYPE buname,
         user_id2 TYPE buname,
         user_id3 TYPE buname,
         user_id4 TYPE buname,
         user_id5 TYPE buname,
       END OF ty_user,
       BEGIN OF ty_users,
         user_id TYPE buname,
       END OF ty_users,
       tt_users TYPE TABLE OF ty_users WITH EMPTY KEY.

DATA(ls_user) = VALUE ty_user( user_id1 = 'USER1' user_id2 = 'USER2' user_id3 = '' user_id4 = 'USER4' user_id5 = 'USER5' ).
ASSIGN ls_user TO FIELD-SYMBOL(<fs_user>).

DATA(lt_users) = REDUCE tt_users( INIT _users TYPE tt_users
                                  FOR comp IN cl_abap_struct_utilities=>filled_components( ls_user )
                                  NEXT _users = VALUE #( BASE _users ( user_id = <fs_user>-(comp-name) ) ) ).

"Other useful methods,
" 1. cl_abap_struct_utilities=>filled_components_c( )
" 2. cl_abap_struct_utilities=>filled_components_x( )

"https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCL_ABAP_STRUCT_UTILITIES.html
"https://github.com/SAP-samples/abap-cheat-sheets/blob/main/22_Released_ABAP_Classes.md#information-about-non-initial-structure-components

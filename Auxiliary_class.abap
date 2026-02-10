"Definition in BDEF
managed implementation in class cl_bil_class unique;
strict ( 2 );
auxiliary class class_name1, class_name2;
...
define behavior for bdef_name alias BdefName
...
{
  ....
}

"Class Definition
CLASS class_name1 DEFINITION PUBLIC
   FOR BEHAVIOR OF bdef_name .... 
    PUBLIC SECTION.
    METHODS eml_with_local_mode.
   ....
ENDCLASS. 
 
CLASS class_name1 IMPLEMENTATION. 
   METHOD eml_with_local_mode.
      MODIFY ENTITIES OF bdef_name IN LOCAL MODE
      ....
   ENDMETHOD.
ENDCLASS.

"More Information - https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/ABAPRAP_AUXILIARY_CLASS.html
"https://www.linkedin.com/feed/update/urn:li:activity:7426987842398003200/

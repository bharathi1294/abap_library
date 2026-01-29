"Accessing Change Information in RAP Using WITH CHANGES
"Variant 1
    READ ENTITIES OF ZRootEntity IN LOCAL MODE
    ENTITY RootEntity WITH CHANGES
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result1).

"Variant 2
    READ ENTITY IN LOCAL MODE ZRootEntity
    WITH CHANGES
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result2).

"Reference - https://github.com/SAP-samples/abap-cheat-sheets/blob/main/08_EML_ABAP_for_RAP.md#accessing-change-information

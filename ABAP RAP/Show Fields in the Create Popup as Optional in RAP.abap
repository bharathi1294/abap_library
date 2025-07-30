"Show Fields in the Create Popup as Optional in RAP
"Step 1 : Add temporary fields to show in the create popup. These will later be copied to the actual fields.
define root view entity ZR_ROOT_ENTITY as select from zcustomer {
  key id as Id,
  fname as Fname,
  lname as Lname,

  @EndUserText.label: 'First Name'
  $projection.Fname as Fname_D,

  @EndUserText.label: 'Last Name'
  $projection.Lname as Lname_D
}

"Step 2: If you have a projection (C_ view), include the temporary fields but hide them from filters and line items.
define root view entity ZC_ROOT_ENTITY
  provider contract transactional_query
  as projection on ZR_ROOT_ENTITY {
  key Id,
  Fname,
  Lname,

  @Consumption.filter.hidden: true
  @UI.lineItem: [{ hidden: true }]
  Fname_D,

  @Consumption.filter.hidden: true
  @UI.lineItem: [{ hidden: true }]
  Lname_D
}

"Step 3: Mark the temporary fields as read-only on update. Use a determination to copy their values to the actual fields on create.
define behavior for ZR_ROOT_ENTITY
...
{
  field ( mandatory : create ) Id;

  field ( readonly : update ) Fname_D, Lname_D;

  determination setNames on modify { create; }
}

"Step 4: Copy temporary field values (Fname_D, Lname_D) to actual fields (Fname, Lname) during creation.
METHOD setNames.
  READ ENTITIES OF ZR_ROOT_ENTITY IN LOCAL MODE
    ENTITY ZR_ROOT_ENTITY
    FIELDS ( Fname_D Lname_D )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  lt_update = VALUE #( FOR lw IN lt_result (
    %tky = lw-%tky
    Fname = lw-Fname_D
    Lname = lw-Lname_D
    %control = VALUE #( Fname = if_abap_behv=>mk-on
                        Lname = if_abap_behv=>mk-on )
  )).

  MODIFY ENTITIES OF ZR_ROOT_ENTITY IN LOCAL MODE
    ENTITY ZR_ROOT_ENTITY
    UPDATE FROM lt_update
    REPORTED DATA(ls_reported)
    FAILED DATA(ls_failed).
ENDMETHOD.

"Step 5: Result On create, popup shows 3 fields: Id (required), Fname_D, and Lname_D (optional).
"After creation, actual fields Fname and Lname are filled and can be edited on the object page.

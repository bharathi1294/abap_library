"Step 1 – Define static default factory action in R_* BDEF
define behavior for ZR_ROOT alias ROOT
{
  create;
  update;
  delete;

  static default factory action createCustomer parameter ZD_CustomerData [1];
}
"Here, createCustomer will be triggered instead of the standard create.

"Step 2 – Create abstract entity for action parameters
@EndUserText.label: 'Customer Data'
define abstract entity ZD_CustomerData
{
    @EndUserText.label: 'Customer ID'
    CustomerId : int4;

    @EndUserText.label: 'First Name'
    FirstName  : abap.char(20);

    @EndUserText.label: 'Last Name'
    LastName   : abap.char(20);
}
"This entity defines the parameters passed to the static action.

"Step 3 – Implement custom logic in the action handler
METHOD createCustomer.
  CHECK keys IS NOT INITIAL.

  MODIFY ENTITIES OF ZR_Root IN LOCAL MODE
    ENTITY Root
    CREATE FIELDS ( id Fname Lname Age )
    WITH VALUE #(
      FOR key IN keys (
        %cid       = key-%cid
        %is_draft  = key-%param-%is_draft
        Id         = key-%param-CustomerId
        Fname      = key-%param-FirstName
        Lname      = key-%param-LastName
        Age        = 25
      )
    )
    MAPPED   mapped
    FAILED   failed
    REPORTED reported.
ENDMETHOD.
"Here, the incoming parameters are mapped to the entity fields before creation.

"Step 4 – Expose the action in ZC_* (projection) BDEF
define behavior for ZC_Root alias Root
{ 
  use create;
  use update;
  use delete;

  use action createCustomer;
}
"This makes the action available in the projection layer.

"Result
"When the Create button is clicked in the SAP Fiori Elements UI: 
"The createCustomer static default factory action is triggered automatically.
"Custom parameter handling and default value logic are executed before entity creation.
"The standard create operation is bypassed (even if enabled).

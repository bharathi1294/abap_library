"Step 1: Define a default function in your Behavior Definition (BDEF)
define behavior for ZR_ROOT_ENTITY alias Travel
....
{
  ...
  create{ default function GetDefaultsForCreate; }
  
}

"Step 2: Implement the logic in the behavior class
METHOD GetDefaultsForCreate.
    result = VALUE #( FOR key IN keys (
          %cid = key-%cid
          %param = VALUE #( CurrencyCode = 'INR'
                            BeginDate = cl_abap_context_info=>get_system_date( )
                            OverallStatus = 'O' ) ) ).
ENDMETHOD.

"Step 3: Use the function in your Projection BDEF(If you defined)
projection;
strict(2);

define behavior for ZC_ROOT_ENTITY alias Travel
...
{
  ...
  use function GetDefaultsForCreate;
}

"Step 4: That’s it! Now when you try to create a new record, the values will be pre-filled automatically 

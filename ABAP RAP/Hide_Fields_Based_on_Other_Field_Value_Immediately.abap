*Use Case: Dynamically Hide Fields Based on EmployeeType Immediately Upon Change*

"Step 1: Add a Derived Field in the Root Entity ZR_SB_EMP_DATA

define root view entity ZR_SB_EMP_DATA
  as select from zsb_emp_data as EmployeeData
{
  ...,
  EmployeeType,
  case EmployeeType
    when 'FT' then cast( 'X' as abap_boolean preserving type )
    else cast( ''  as abap_boolean preserving type )
  end as IsFullTimeEmployee
}

"This derived field IsFullTimeEmployee is used to control visibility logic based on EmployeeType.

"Step 2: Expose the Field in Your Projection View

define root view entity ZC_SB_EMP_DATA
  provider contract transactional_query
  as projection on ZR_SB_EMP_DATA
{
  ...,
  EmployeeType,
  IsFullTimeEmployee
}

"Step 3: Apply the Visibility Annotation to Your Target Field. Use the @UI.hidden annotation to conditionally hide the field (e.g., MobileNumber) based on IsFullTimeEmployee.

annotate view ZC_SB_EMP_DATA with
{
  ...,
  @UI.hidden: #( IsFullTimeEmployee )
  MobileNumber;
}

"Step 4: Add a Determination in the Root BDEF to Recalculate the Boolean Field on Change, Also declare a side effect to notify the UI of the dependent field update.

define behavior for ZR_SB_EMP_DATA alias EmployeeData
...
{
  ...
  determination setVisibility on modify { field EmployeeType; }
  side effects { field EmployeeType affects field IsFullTimeEmployee; }
}

"Step 5: Implement the Determination Logic to Update IsFullTimeEmployee immediately when EmployeeType changes.

METHOD setVisibility.
  DATA: lt_update TYPE TABLE FOR UPDATE zr_sb_emp_data.

  READ ENTITIES OF zr_sb_emp_data IN LOCAL MODE
    ENTITY EmployeeData
    FIELDS ( EmployeeType )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_employee_data).

  lt_update = VALUE #( FOR ls_employee IN lt_employee_data (
    %tky = ls_employee-%tky
    IsFullTimeEmployee = xsdbool( ls_employee-EmployeeType = 'FT' )
    %control = VALUE #( IsFullTimeEmployee = if_abap_behv=>mk-on ) ) ).

  MODIFY ENTITIES OF zr_sb_emp_data IN LOCAL MODE
    ENTITY EmployeeData
    UPDATE FROM lt_update
    REPORTED DATA(lt_reported).

  reported = CORRESPONDING #( DEEP lt_reported ).
ENDMETHOD.
  
"Step 6: Enable Side Effects in the Projection BDEF

use side effects;
define behavior for ZC_SB_EMP_DATA alias EmployeeData
{
  ...
}

"Step 7: That’s it! Now, the field (e.g., MobileNumber) will be shown or hidden immediately based on the selected EmployeeType value without requiring a page reload.
"PT - Part Time Employee
"FT - Full Time Employee

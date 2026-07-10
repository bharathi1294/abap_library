# Editable Virtual Elements: Reading and Saving Long Text

This guide demonstrates how to implement an **editable virtual element** in RAP to read and save SAP long texts using the `READ_TEXT` and `SAVE_TEXT` function modules.

## Overview
| Field | Layer | Purpose |
| --- | --- | --- |
| `LongText` | Base (R) View | Staging field that temporarily stores the value mapped from the virtual element through the augment implementation |
| `VirtualLongText` | Projection (C) View | Editable virtual element that reads the SAP long text at runtime using `ZCL_READ_LONG_TEXT` |

## Step 1: Add a Staging Field to the Base View Entity

Add a staging field to the root view entity. This field stores the value copied from the virtual element during the augment phase.

> **Note:** The maximum supported length for a CDS character field is **1,333 characters**.

```abap
define root view entity ZR_RootEntity
  as select from ztable
{
  ...
  cast( '' as abap.char( 1333 ) ) as LongText
}
```

## Step 2: Add a Virtual Element to the Projection View

Define a virtual element in the projection view and associate it with the virtual element calculation class. Hide the staging field from the UI since it is only used internally.

```abap
define root view entity ZC_RootEntity
  provider contract transactional_query
  as projection on ZR_RootEntity
{
  ...

  @ObjectModel.virtualElement: true
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_READ_LONG_TEXT'
  @UI.multiLineText: true
  virtual VirtualLongText : abap.char( 1333 ),

  @UI.hidden: true
  LongText
}
```

## Step 3: Implement the Virtual Element Calculation Class

Implement the calculation class to read the SAP long text using the `READ_TEXT` function module and populate the virtual element.

For more information about virtual elements, refer to the SAP documentation:
https://help.sap.com/docs/ABAP_PLATFORM_NEW/fc4c71aa50014fd1b43721701471913d/319380e0cef94051ae9aa292ffadb59a.html

```abap
CLASS ZCL_READ_LONG_TEXT DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.

CLASS ZCL_READ_LONG_TEXT IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA entities TYPE TABLE OF ZC_RootEntity.

    entities = CORRESPONDING #( it_original_data ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      DATA(lv_longtext) = VALUE string( ).

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          " Pass the required key fields
          ...
        IMPORTING
          ...
        EXCEPTIONS
          ...

      <entity>-VirtualLongText = lv_longtext.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( entities ).

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.

ENDCLASS.
```

## Step 4: Configure the Projection Behavior Definition

Register the projection implementation class and enable `augment` for both **create** and **update** operations.

Declaring the virtual field as `field ( modify )` has two purposes:

- Makes the virtual element editable in the UI.
- Ensures the field value is available in the projection BIL class. Without this declaration, the value of `VirtualLongText` is not passed to the `augment_create` and `augment_update` methods.

For more information about augmentation, refer to the SAP documentation:
https://help.sap.com/docs/ABAP_PLATFORM_NEW/fc4c71aa50014fd1b43721701471913d/346c2b7516ce4176bbb4daebaa80c2ca.html

```abap
projection implementation in class ZBP_C_RootEntity unique;
strict ( 2 );
use draft;

define behavior for ZC_RootEntity alias ZcRootEntity
use etag
{
  use create ( augment );
  use update ( augment );
  use delete;

  ...

  field ( modify ) VirtualLongText;

  ...
}
```

## Step 5: Map the Virtual Element to the Staging Field

Inside the projection BIL class, copy the value from `VirtualLongText` to `LongText` in the `augment_update` method. This allows the value to be stored in the RAP draft table and passed to the base BO during save.

```abap
METHOD augment_update.

  DATA lt_update TYPE TABLE FOR UPDATE ZR_RootEntity.

  LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

    APPEND VALUE #(
      %cid_ref          = <fs_entity>-%cid_ref
      %key              = CORRESPONDING #( <fs_entity>-%key )
      %is_draft         = <fs_entity>-%is_draft
      LongText          = <fs_entity>-VirtualLongText
      %control-LongText = if_abap_behv=>mk-on
    ) TO lt_update.

  ENDLOOP.

  MODIFY AUGMENTING ENTITY ZR_RootEntity
    UPDATE FROM lt_update.

ENDMETHOD.
```
## Step 6: Enable Additional Save

Enable **additional save** in the base behavior definition so that RAP invokes the `save_modified` method during the save sequence.

```abap
managed with additional save implementation in class ZBP_R_RootEntity unique;

define behavior for ZR_RootEntity alias R_RootEntity
{
  ...
}
```

## Step 7: Save the Long Text

In `save_modified`, read the value from `LongText` and pass it to the `SAVE_TEXT` function module.

```abap
METHOD save_modified.
  LOOP AT create-R_RootEntity ASSIGNING FIELD-SYMBOL(<entity>).
    DATA(lv_long_text) = <entity>-LongText.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        " Pass the relevant parameters here
        ...
      EXCEPTIONS
        ...
  ENDLOOP.

  LOOP AT update-R_RootEntity ASSIGNING FIELD-SYMBOL(<entity>).
    DATA(lv_long_text) = <entity>-LongText.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        " Pass the relevant parameters here
        ...
      EXCEPTIONS
        ...
  ENDLOOP.
ENDMETHOD.
```

## Step 8: No Explicit Commit Is Required

No explicit `COMMIT WORK` is required.

After `save_modified` completes successfully, the RAP framework automatically performs the database commit. The framework then issues a **GET** request, which triggers the virtual element calculation class again. As a result, the updated long text is read from SAPscript and displayed immediately in the UI.

## Flow Summary

```text
UI
 ↓
VirtualLongText (Virtual Element)
 ↓
augment_create / augment_update
 ↓
LongText (Staging Field)
 ↓
Draft Table
 ↓
save_modified
 ↓
SAVE_TEXT
 ↓
Implicit RAP Commit
 ↓
GET Request
 ↓
READ_TEXT
 ↓
VirtualLongText Updated in UI
```

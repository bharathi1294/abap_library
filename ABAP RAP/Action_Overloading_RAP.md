# Action Overloading in SAP ABAP RAP
Action Overloading allows you to add an action defined on one entity to the object page list table of another entity.

In this example, the action is defined on the Root entity, but the action button is displayed in the Child entity table on the Object Page. When the user clicks the button, the Root action is triggered, and it uses the Root instance context to create one or multiple Child records based on the required business logic.

### Behavior Definition
Define the action as an instance action on the Root. The side effect ensures that the Child entity is refreshed after the action is executed.
```abap
define behavior for ZI_ROOT alias Root {
  action createItemFromRoot;

  side effects {
    action createItemFromRoot affects entity _Child;
  }
}
```

### Projection Behavior Definition
Expose the Root action in the projection behavior so that it can be consumed by the UI.
```abap
projection;
...
use side effects;

define behavior for ZC_Root alias Root
{
  ....
  use action createItemFromRoot;
  ....
}
```

### Child Metadata Extensions
Although the action is defined on the **Root**, we can display it in the **Child table toolbar** by referencing the action using its **qualified action name** (`ProjectionEntity.ActionName`).

```abap
annotate view ZC_CHILD with {
...
@UI.lineItem: [
  {
    position: 10,
    type: #FOR_ACTION,
    dataAction: 'ZC_Root.createItemFromRoot',
    label: 'Create Item From Root'
  }
]
FieldFromChildCDS;
...
}
```

### BIL Logic
Since this is a Root instance action, keys contains the Root instance context. We can use %tky to identify the Root and then create multiple Child records using CREATE BY _Child.
```abap
METHOD createItemFromRoot.
  CHECK keys IS NOT INITIAL.
  DATA lt_create TYPE TABLE FOR CREATE zi_root/_child.

  lt_create = VALUE #(
    FOR key IN keys (
      %tky = key-%tky
      %target = VALUE #(
        FOR i = 1 WHILE i <= 2 (
          %cid = |CID_{ i }|
          %is_draft = key-%is_draft
          ChildDate = cl_abap_context_info=>get_system_date( )
          ChildName = |Created From Root_{ i }|
          %control = VALUE #(
              ChildDate = if_abap_behv=>mk-on
              ChildName = if_abap_behv=>mk-on )
        )
      )
    )
  ).

  MODIFY ENTITIES OF zi_root IN LOCAL MODE
    ENTITY Root
    CREATE BY _Child
    FROM lt_create
    REPORTED reported
    FAILED failed.
ENDMETHOD.
```

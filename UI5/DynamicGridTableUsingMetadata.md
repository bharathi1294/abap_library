# Dynamic Grid Table — Metadata Driven Columns

When the standard Fiori floorplan cannot support a requirement, a full UI breakout is the way to go custom dialog, custom API call, full control. The challenge is keeping the frontend in sync with the backend without hardcoding every field.

The solution: read `@UI.LineItem` annotations from the OData MetaModel at runtime. Three values — `field`, `label`, `hidden` — are enough to build the entire Grid Table, resolve column headers from the backend, and construct a `$select` that only fetches visible fields.

- Add a field in CDS with lineItem annotation - column appears automatically
- Set `hidden: true` - gone from the UI and the API call
- Rename a label in CDS - reflected in the column header instantly
- No JS or XML change needed for any of the above

---

## ABAP CDS

```abap
@EndUserText.label: 'Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCLASS'
define custom entity ZCustomEntity
 with parameters     
    P_CustomerID : char40,
    P_Status     : char40
{
    @UI.lineItem: [{ position: 10, label: 'Customer' }]
    @EndUserText.label: 'Customer'
    key customer : char40,
    
    @UI.lineItem: [{ position: 20, label: 'Order ID', hidden: true }]
    @EndUserText.label: 'Order ID'
    order_id : char10,
    
    @UI.Hidden: true
    @EndUserText.label: 'Internal Key'
    internal_key : char120
}
```

---

## XML

```xml
<t:Table id="idMyTable" rows="{tableModel>/items}" width="100%">
    <t:columns/>   <!-- built programmatically -->
</t:Table>
```

---

## JS

```javascript
var oMeta       = oView.getModel().getMetaModel();
var sEntityPath = "/MyEntity/Set/";

var aLineItems = oMeta.getObject(
    sEntityPath + "@com.sap.vocabularies.UI.v1.LineItem"
) || [];

// Step 1 — resolve field metadata from annotations
var aColumns = aLineItems.map(function (oItem) {
    var sField = oItem.Value.$Path;
    return {
        field:   sField,
        label:   oLineItem.Label
                 ||oMeta.getObject(sEntityPath + sField + "@com.sap.vocabularies.Common.v1.Label")
                 || sField,
        visible: !oItem["@com.sap.vocabularies.UI.v1.Hidden"] && !oMeta.getObject(sEntityPath + sField + "@com.sap.vocabularies.UI.v1.Hidden")
    };
});

// Step 2 — get table reference and build columns
var oTable = oView.byId("idMyTable");
oTable.destroyColumns();
aColumns.forEach(function (oCol) {
    oTable.addColumn(new Column({
        visible:  oCol.visible,
        label:    new Label({ text: oCol.label }),
        template: new Text({ text: "{tableModel>" + oCol.field + "}" })
    }));
});

// Step 3 — call API with filters, only visible fields in $select
var aSelectFields = aColumns
    .filter(function (c) { return c.visible; })
    .map(function (c) { return c.field; });

var oContexts = await oView.getModel().bindList(
    "/ZCustomEntity(P_CustomerID='" + sCustomerId + "',P_Status='" + sStatus + "')/Set",
    undefined, undefined, undefined,
    { $select: aSelectFields.join(",") }
).requestContexts(0, 99999999);

// Step 4 — create and set model directly after call returns
oView.setModel(new JSONModel({
    items: oContexts.map(function (c) { return c.getObject(); })
}), "tableModel");
```

---

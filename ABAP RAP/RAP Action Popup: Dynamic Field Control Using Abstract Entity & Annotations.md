### RAP Action Popup: Dynamic Field Control Using Abstract Entity & Annotations
> ⚠️ Note: Applicable only to SAP Fiori elements for OData V4. The behavior may vary depending on the SAP UI5 version. Observed working in SAP S/4HANA 2023+(SAP UI5 1.120+).
## Step 1: Define the Action in Metadata Extension / Projection View
```abap
annotate view ZC_RootEntity with {
  @UI: { 
    lineItem: [ 
      { 
        position: 10, 
        type: #FOR_ACTION, 
        dataAction: 'ActionWithPopup', 
        label: 'Action With Popup' 
      }  
    ]  
  } 
  FieldName;
}
````
---

## Step 2: Create an Abstract Entity (Popup)

```abap
@EndUserText.label: 'Action with Popup'
define abstract entity ZD_ActionWithPopup {

  @Consumption.valueHelpDefinition: [
    { entity: { name: 'ZI_ActionPropBehvValue', element: 'Behaviour' } }
  ]
  @EndUserText.label: 'Behaviour'
  Behaviour : abap.char( 1 );
  
  @EndUserText.label: 'Field 1'
  Field : abap.char( 10 );

  // Used as a comparison value (instead of hardcoding in XML)
  @UI.hidden: true
  @UI.defaultValue: 'M'
  mandatoryDefaultValue : abap.char( 1 );
}
```

---

## Step 3: Expose the Action in Behavior Definition (BDEF)

```abap
define behavior for ZR_RootEntity alias RootEntity
...
{
  action ActionWithPopup parameter ZD_ActionWithPopup result [0..1] $self;
}
```

---

## Step 4: Expose the Action in Projection BDEF

```abap
define behavior for ZC_RootEntity alias RootEntity
...
{
  use action ActionWithPopup;
}
```

---

## Step 5: Create Service Definition & Binding
```md
Create a Service Definition to expose the entity. Then create a Service Binding (OData V4) to make it available for UI consumption.
```
---

## Step 6: Add Dynamic UI Logic in Annotations.xml
```md
Create a new Fiori application using Fiori App Generator in VS Code or BAS. Then navigate to the annotations file
```
**Path:**
`project_name/webapp/annotations/annotation.xml`

```xml
<Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="local">
    <Annotations Target="SAP__self.ActionWithPopup/Field">
        <!-- Control Field Behavior Dynamically -->
        <Annotation Term="Common.FieldControl">
            <If>
                <!-- If Behaviour = 'R', make field ReadOnly -->
                <Eq>
                    <Path>Behaviour</Path>
                    <String>R</String>
                </Eq>
                <EnumMember>Common.FieldControlType/ReadOnly</EnumMember>
                <!-- Else check for Mandatory condition -->
                <If>
                    <!-- If Behaviour = mandatoryDefaultValue(From Abstract Entity), make field Mandatory -->
                    <Eq>
                        <Path>Behaviour</Path>
                        <Path>mandatoryDefaultValue</Path>
                    </Eq>
                    <EnumMember>Common.FieldControlType/Mandatory</EnumMember>
                    <!-- Default case: Optional -->
                    <EnumMember>Common.FieldControlType/Optional</EnumMember>
                </If>
            </If>
        </Annotation>
        <!-- Control Field Visibility Dynamically -->
        <Annotation Term="UI.Hidden">
            <If>
                <!-- If Behaviour = 'H', hide the field -->
                <Eq>
                    <Path>Behaviour</Path>
                    <String>H</String>
                </Eq>
                <Bool>true</Bool>
                <!-- Otherwise, show the field -->
                <Bool>false</Bool>
            </If>
        </Annotation>
    </Annotations>
</Schema>
```

---

## 🔗 References
- [SAP UI5 Documentation – Field Control & Annotations](https://ui5.sap.com/1.136.0/#/topic/f49a0f7eaafe444daf4cd62d48120ad0)
- [SAP UI5 Documentation - Hide Fields using EDMJson](https://ui5.sap.com/1.136.0/#/topic/ca00ee45fe344a73998f482cb2e669bb)
---

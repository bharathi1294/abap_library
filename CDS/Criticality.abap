Highlight Line Items and Columns Based on Criticality
"Step 1: Derive the CriticalityCode Based on OverallStatus
define root view entity ZR_ROOT_ENTITY
{
  ...
  OverallStatus,
  case $projection.OverallStatus
           when 'A' then 3 // 3 - Green
           when 'X' then 1 // 2 - Red
           when 'O' then 2 // 1 - Yellow
           else 0          // 0 - Neutral
           end as CriticalityCode
}
"Step 2: Expose CriticalityCode in the Projection View
define root view entity ZC_ROOT_ENTITY
  provider contract transactional_query
  as projection on ZR_ROOT_ENTITY
{
  ...
  OverallStatus,
  CriticalityCode
}
"Step 3: Annotate in Metadata Extension
@UI.lineItem: [{ criticality: 'CriticalityCode' }]
annotate view ZC_ROOT_ENTITY with {
  ....
  @UI: { lineItem: [{position: 10, importance: #HIGH, criticality: 'CriticalityCode', criticalityRepresentation: #WITH_ICON }] }
  OverallStatus;
}

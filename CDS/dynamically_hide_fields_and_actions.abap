"New field in the CDS View
case when  EmployeeStatus = 'RETIRED'
     then cast( 'X' as abap_boolean preserving type )
     else cast( ''  as abap_boolean preserving type )
     end as HideCourseList

"Metadata Extensions
"Hide Facet in the Object Page
  @UI.facet: [{ type: #LINEITEM_REFERENCE,
                position: 20,
                id: 'CourseData',
                label: 'Courses',
                targetElement: '_Courses',
                purpose: #STANDARD,
                hidden: #(HideCourseList) } 
                
"Hide Standard Operations in the object page - Avaialble from S4HANA 2023+
@UI.createHidden: #(HideCourseList)
@UI.updateHidden: #(HideCourseList)
@UI.deleteHidden: #(HideCourseList)
annotate entity .....
  with
  
"Hide Field
@UI.hidden: #(HideCourseList)
field_name;

"Hide field from Facet Group
@UI.identification: [{ hidden: #(HideCourseList) }]
field_name;

@UI.fieldGroup: [{ hidden: #(HideCourseList) }]
field_name;

"Etc,.

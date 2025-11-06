"Display Message Strip by Default in Object Page using Instance Features
"Step 1 – Add actions in Metadata Extensions
annotate view YR_TRAVELTP with
{
@UI.identification: [
  { type: #FOR_ACTION, label: 'Accept', dataAction: 'AcceptTravel', position: 10 },
  { type: #FOR_ACTION, label: 'Reject', dataAction: 'RejectTravel', position: 20 }
]
....
}


"Step 2 – Update the Behavior Definition (BDEF)
define behavior for YR_TRAVELTP alias Travel 
.....
{
  .....
  update ( features : instance );
  field ( features : instance ) OverallStatus;
  draft action ( features : instance ) Edit;

  action ( features : instance ) AcceptTravel result [1] $self;
  action ( features : instance ) RejectTravel result [1] $self; 
  ....
}


"Step 3 – Implement Logic in the Behavior Implementation (BIL)
METHOD AcceptTravel.
    MODIFY ENTITIES OF YR_TRAVELTP IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky OverallStatus = 'A' ) ).

    READ ENTITIES OF YR_TRAVELTP IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky %param = travel ) ).
ENDMETHOD.

METHOD RejectTravel.
    MODIFY ENTITIES OF YR_TRAVELTP IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky OverallStatus = 'X' ) ).

    READ ENTITIES OF YR_TRAVELTP IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky %param = travel ) ).
ENDMETHOD.

METHOD get_instance_features.
  READ ENTITIES OF YR_TRAVELTP IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

  LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
    reported-travel = VALUE #( BASE reported-travel ( %tky = <travel>-%tky %state_area = 'DEFAULT_MESSAGE' ) ).

    IF <travel>-EndDate < cl_abap_context_info=>get_system_date( ) AND <travel>-EndDate IS NOT INITIAL.
      DATA(is_travel_completed) = abap_true.
      reported-travel = VALUE #( BASE reported-travel (
                                 %tky = <travel>-%tky
                                 %state_area = 'DEFAULT_MESSAGE'
                                 %msg = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-information
                                          text     = 'Travel completed' ) ) ).

    ELSEIF <travel>-OverallStatus = 'A'.
      reported-travel = VALUE #( BASE reported-travel (
                                 %tky = <travel>-%tky
                                 %state_area = 'DEFAULT_MESSAGE'
                                 %msg = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-success
                                          text     = 'Travel Accepted' ) ) ).

    ELSEIF <travel>-OverallStatus = 'X'.
      reported-travel = VALUE #( BASE reported-travel (
                                 %tky = <travel>-%tky
                                 %state_area = 'DEFAULT_MESSAGE'
                                 %msg = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = 'Travel Rejected' ) ) ).
    ENDIF.

    result = VALUE #( BASE result
                      ( %tky = <travel>-%tky
                        %update = COND #( WHEN is_travel_completed = abap_true
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled )
                        %action = VALUE #(
                          Edit = COND #( WHEN is_travel_completed = abap_true
                                         THEN if_abap_behv=>fc-o-disabled
                                         ELSE if_abap_behv=>fc-o-enabled )
                          AcceptTravel = COND #( WHEN is_travel_completed = abap_true OR <travel>-OverallStatus = 'A'
                                                 THEN if_abap_behv=>fc-o-disabled
                                                 ELSE if_abap_behv=>fc-o-enabled )
                          RejectTravel = COND #( WHEN is_travel_completed = abap_true OR <travel>-OverallStatus = 'X'
                                                 THEN if_abap_behv=>fc-o-disabled
                                                 ELSE if_abap_behv=>fc-o-enabled ) ) ) ).
  ENDLOOP.
ENDMETHOD.

"Step 4 – Expose the actions in the projection BDEF YC_TRAVELTP (if not already exposed)
"Step 5 – Test and See the Result
"When you open the Object Page, the relevant message strip will appear automatically based on the travel status — Completed, Accepted, or Rejected.

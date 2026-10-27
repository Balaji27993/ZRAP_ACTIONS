CLASS lhc_zr_ytravel_app_act DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS: BEGIN OF travel_status,
                 Accepted TYPE c LENGTH 1 VALUE 'A',
                 Rejected TYPE c LENGTH 1 VALUE 'X',
               END OF travel_status.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Travel
        RESULT result,
      earlynumbering_create FOR NUMBERING
       entities FOR CREATE Travel,
      ModifyStatus FOR MODIFY
       keys FOR ACTION Travel~ModifyStatus,
      TotalPrice FOR MODIFY
       keys FOR ACTION Travel~TotalPrice RESULT result,
      DisplayPrice FOR MODIFY
       keys FOR ACTION Travel~DisplayPrice RESULT result,
*      get_instance_features FOR INSTANCE FEATURES
*            keys REQUEST requested_features FOR Travel RESULT result,
*      get_global_features FOR GLOBAL FEATURES
*            REQUEST requested_features FOR Travel RESULT result,
      StatusUpdate FOR MODIFY
            keys FOR ACTION Travel~StatusUpdate RESULT result,
      get_instance_features FOR INSTANCE FEATURES
            keys REQUEST requested_features FOR Travel RESULT result.

    METHODS AcceptTravel FOR MODIFY
       keys FOR ACTION Travel~AcceptTravel RESULT result.

    METHODS RejectTravel FOR MODIFY
       keys FOR ACTION Travel~RejectTravel RESULT result.
    METHODS CopyTravel FOR MODIFY
       keys FOR ACTION Travel~CopyTravel.
    METHODS CreateTravel FOR MODIFY
       keys FOR ACTION Travel~CreateTravel.
    METHODS createdata FOR MODIFY
       keys FOR ACTION Travel~createdata.
ENDCLASS.

CLASS lhc_zr_ytravel_app_act IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(ls_entities).

      IF ls_entities-%key-TravelID IS NOT INITIAL.
        ls_entities-%key-TravelID = ls_entities-TravelID.
        ls_entities-%key-TravelUUID = ls_entities-TravelUUID.

        APPEND VALUE #(  %cid = ls_entities-%cid
                         %is_draft = ls_entities-%is_draft
                         %key = ls_entities-%key ) TO mapped-travel.
      ELSE.

        TRY.
            cl_numberrange_runtime=>number_get(
                      EXPORTING
*          ignore_buffer     =
                        nr_range_nr       = '01'
                        object            = '/DMO/TRV_M'
                        quantity          = 1
*      subobject         =
*      toyear            =
                      IMPORTING
                        number            = DATA(lv_last)
                        returncode        = DATA(lv_rc)
                        returned_quantity = DATA(lv_rcqty)
                    ).
          CATCH cx_nr_object_not_found.
          CATCH cx_number_ranges.
        ENDTRY.
*    "mapping the primary key

        ls_entities-%key-TravelID = lv_last.
        TRY.
            ls_entities-%key-TravelUUID = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND VALUE #( %cid = ls_entities-%cid
                        %is_draft = ls_entities-%is_draft
                        %key = ls_entities-%key ) TO mapped-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD ModifyStatus.

    MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    UPDATE FIELDS ( Status ) WITH VALUE #(  FOR key IN keys
                                              (  %key-TravelUUID = key-TravelUUID
                                                 %key-TravelID = key-TravelID
                                                 status = key-%param-status ) )
                                                 REPORTED DATA(lt_reported)
                                                 FAILED DATA(lt_status_failed).

  ENDMETHOD.

  METHOD TotalPrice.
    " when we select the entry and click on price button it will calculate the booking price and total price
    " then it will update with total price for ex booking is 100 and travel is 200 after clicking this action total
    " total price column will be updated with 300
    DATA: lt_modify TYPE TABLE FOR UPDATE zr_ytravel_app_act.


    " First read the entity
    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
     ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    "looping the result to get all row data.
    LOOP AT  lt_result  ASSIGNING FIELD-SYMBOL(<fs_result>).

      <fs_result>-TotalPrice = <fs_result>-BookingFee + <fs_result>-TotalPrice.

    ENDLOOP.

    "updating the internal table to back to the column
    lt_modify = CORRESPONDING #( lt_result ).

    " Modifying the column.
    MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY travel
    UPDATE FIELDS ( totalPrice ) WITH lt_modify REPORTED DATA(lt_report).
    "the below result parameter is use to automatic UI update no need to refresh URL.
    result = VALUE #(  FOR ls_result IN lt_result
                         (  %tky = ls_result-%tky
                            %param = ls_result ) ).

    "Below code will be shown the Sucess message

    reported-travel = VALUE #( (  %tky = keys[ 1 ]-%tky
                               %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                             text  = |Total Price Updated|
                                                             ) ) ).
  ENDMETHOD.

  METHOD DisplayPrice.

    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_Price).


    "to get total amount

    DATA(lv_grand_tot) = REDUCE decfloat34(  INIT sum = 0
                                             FOR ls_price IN lt_price
                                             NEXT sum = sum + ls_price-TotalPrice ).
    "Reading Message form msg class

    DATA(lo_msg) = new_message(
                     id       = 'ZM_MSG'
                     number   = '000'
                     severity = if_abap_behv_message=>severity-information
                     v1       = |{ lv_grand_tot }|
*                      v2       =
*                      v3       =
*                      v4       =
                   )  .

    "to display in UI need to use repoted parameter

    reported-travel = VALUE #( (  %tky = keys[ 1 ]-%tky
                                %msg = lo_msg ) ).



  ENDMETHOD.

*  METHOD get_instance_features.
*
*    "Based on condition we need to enable or disable the delete action
*
*    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
*      FIELDS ( Status ) WITH CORRESPONDING #(  keys ) RESULT DATA(lt_status).
*
*
*    IF lt_status IS NOT INITIAL.
*
*      result = VALUE #(  FOR ls_status IN lt_status
*                          (  %tky = ls_status-%tky
*                            %features-%delete = COND #( WHEN ls_status-Status = 'X'
*                                                         THEN if_abap_behv=>fc-o-disabled  ) ) ).
*    ENDIF.
*
*  ENDMETHOD.

*  METHOD get_global_features.
*
*    "Global feacture control it works on entity level
*    result-%update = if_abap_behv=>fc-o-disabled.
*
*  ENDMETHOD.

  METHOD StatusUpdate.
    "Update the status based on the condition

    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
     ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_update) FAILED DATA(lt_failed).

    LOOP AT lt_update ASSIGNING FIELD-SYMBOL(<fs_update>).
      IF <fs_update>-Status = 'A'.

        APPEND VALUE #(  %tky = <fs_update>-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = <fs_update>-%tky
                         %msg = new_message_with_text(
                                         severity = if_abap_behv_message=>severity-error
                                         text = <fs_update>-TravelID && 'Travel Status Should not be A'
                                         )  ) TO reported-travel.
      ELSE.
        <fs_update>-Status = 'O'.
      ENDIF.
    ENDLOOP.
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
       UPDATE FIELDS ( Status ) WITH CORRESPONDING #( lt_update ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_state).

    LOOP AT lt_state ASSIGNING FIELD-SYMBOL(<fs_state>).

      reported-travel = VALUE #( BASE reported-travel (  %tky = <fs_state>-%tky
                                                         %state_area = 'DEFAULT_ACCEPT' ) ).
*       reported-travel = VALUE #( BASE reported-travel (  %tky = <fs_state>-%tky
*                                                         %state_area = 'DEFAULT REJECT' ) ).

      IF <fs_state>-Status = 'A'.
        reported-travel = VALUE #( BASE reported-travel (  %tky = <fs_state>-%tky
                                                         %state_area = 'DEFAULT_ACCEPT'
                                                         %msg = new_message_with_text(
                                                                      severity = if_abap_behv_message=>severity-success
                                                                      text = 'Travel Accepted' ) ) ).

      ELSEIF
      <fs_state>-Status = 'X'.
        reported-travel = VALUE #( BASE reported-travel (  %tky = <fs_state>-%tky
                                                          %state_area = 'DEFAULT_ACCEPT'
                                                          %msg = new_message_with_text(
                                                                       severity = if_abap_behv_message=>severity-error
                                                                       text = 'Travel Rejceted' ) ) ).

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD AcceptTravel.

    MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
     UPDATE FIELDS ( Status ) WITH VALUE #(  FOR key IN keys
                                           (  %tky = key-%tky
                                              Status = travel_status-accepted ) ) FAILED DATA(lt_failed).
    "Once update the DB again the updated data should read.

    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_accept).

    RESult = VALUE #(  FOR accept IN lt_accept
                       (  %tky = accept-%tky
                          %param = accept ) ).
  ENDMETHOD.

  METHOD RejectTravel.

    MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
   UPDATE FIELDS ( Status ) WITH VALUE #(  FOR key IN keys
                                         (  %tky = key-%tky
                                            Status = travel_status-rejected ) ) FAILED DATA(lt_failed).

    "Once update the DB again the updated data should read.

    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_reject).

    RESult = VALUE #(  FOR ls_reject IN lt_reject
                       (  %tky = ls_reject-%tky
                          %param = ls_reject ) ).
  ENDMETHOD.

  METHOD CopyTravel.

    DATA: lt_data TYPE TABLE FOR CREATE zr_ytravel_app_act.
    " Read the entity

    READ ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_copy).

    LOOP AT lt_copy ASSIGNING FIELD-SYMBOL(<fs_copy>).
      " for create %Cid is imp
      APPEND VALUE #(
       %Cid = keys[ KEY entity %key = <fs_copy>-%key ]-%cid
       %is_draft =  keys[ KEY entity %key = <fs_copy>-%key ]-%param-%is_draft
       %data = CORRESPONDING #( <fs_copy> EXCEPT TravelUUID travelId ) ) TO lt_data .

    ENDLOOP.

    MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
    CREATE FIELDS ( AgencyID CustomerID BeginDate EndDate BookingFee TotalPrice Description ) WITH lt_data
     MAPPED DATA(lt_mapped).

    mapped-travel = lt_mapped-travel.

  ENDMETHOD.

  METHOD CreateTravel.
    " when you click on create travle button it will automatically create the record with below values
    MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
      CREATE FROM VALUE #(  FOR ls_create IN keys (
                              %cid = ls_create-%cid
                              AgencyID = '7003'
                              CustomerID = '4'
                              TotalPrice = '1000'
                              BookingFee = '100'
                              Status = 'P'
                              %control = VALUE #(  AgencyID = if_abap_behv=>mk-on
                                                   CustomerID = if_abap_behv=>mk-on
                                                   TotalPrice = if_abap_behv=>mk-on
                                                   BookingFee = if_abap_behv=>mk-on
                                                   Status = if_abap_behv=>mk-on
                                                ) ) ) MAPPED mapped.
  ENDMETHOD.

  METHOD createdata.

"When you click on create button it will show the popup with status and description we have to pass the values
"and once we click on continue it will navigate to the create screen
"we need enter the other values and create the record.
    IF keys IS NOT INITIAL.

      MODIFY ENTITIES OF zr_ytravel_app_act IN LOCAL MODE ENTITY Travel
      CREATE FIELDS (  Status Description  ) WITH VALUE #( FOR ls_data IN keys (
                                                             %cid = ls_data-%cid
                                                             %is_draft = ls_data-%param-%is_draft
                                                             status = ls_data-%param-status
                                                             Description = ls_data-%param-description
                                                           ) ) MAPPED mapped FAILED failed REPORTED reported.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*& Report zcoroutines4abap_demo
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcoroutines4abap_dem02.

CLASS zcl_example_coroutine DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_coroutine_scope.

    METHODS:
      constructor
        IMPORTING
          iv_recipient TYPE bcs_address.
    METHODS:
      send_email.
  PRIVATE SECTION.
    DATA:recipient TYPE bcs_address.
ENDCLASS.

CLASS zcl_example_coroutine IMPLEMENTATION.
  METHOD constructor.
    me->recipient = iv_recipient.
  ENDMETHOD.
  METHOD zif_coroutine_scope~launch.
    send_email( ).
  ENDMETHOD.
  METHOD send_email.
    DATA:lo_msg TYPE REF TO cl_bcs_message.

    SELECT * FROM tstc INTO TABLE @DATA(lt_tstc).

    TRY.
        cl_salv_table=>factory(
            IMPORTING
                r_salv_table = DATA(lo_salv)
            CHANGING
                t_table = lt_tstc
        ).
      CATCH cx_root.
    ENDTRY.

    lo_msg = NEW #( ).
    lo_msg->add_recipient( me->recipient ).
    lo_msg->set_subject( 'Example Mail Subj.' ).
    lo_msg->set_main_doc( 'Example Mail Content' ).
    lo_msg->add_attachment(
        EXPORTING
        iv_doctype = 'XLS'
        iv_filename = 'DOC.xlsx'
        iv_contents_bin = lo_salv->to_xml( if_salv_bs_xml=>c_type_xlsx )
     ).

    TRY.
        lo_msg->send( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  DATA: lo_task         TYPE REF TO zif_coroutine_task,
        lo_example_work TYPE REF TO zcl_example_coroutine.

  " Create an instance of the coroutine class
  lo_example_work = NEW zcl_example_coroutine( iv_recipient = 'furkan51cosgun@gmail.com' ).

  " Start the coroutine
  lo_task = zcl_coroutine_manager=>run( lo_example_work ).

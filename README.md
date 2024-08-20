# COROUTINES FOR ABAP
This project showcases the use of coroutines in ABAP for handling asynchronous operations. Coroutines enable the concurrent execution of tasks, allowing you to perform operations such as database queries and background processing more efficiently. By using coroutines, you can execute tasks asynchronously and manage their completion within your ABAP programs.

## License
This project is licensed under the [MIT License](LICENSE). See the LICENSE file for details.

## Contents
- [Overview](#overview)
- [Examples](#examples)
  - [Awaiting Results from a Coroutine](#awaiting-results-from-a-coroutine)
  - [Background Processing with Coroutines](#background-processing-with-coroutines)

### Overview
This project provides a framework for implementing coroutines in ABAP. Coroutines are designed to handle multiple concurrent operations, making them useful for optimizing performance and enhancing the responsiveness of your applications. The framework includes methods for starting, managing, and awaiting coroutines, enabling more efficient processing of asynchronous tasks.

### Examples

#### Awaiting Results from a Coroutine
This example demonstrates how to use a coroutine to perform an asynchronous database query and then retrieve the results. The coroutine queries material data from the `MARA` table based on a specified material number range and returns the results when the operation is completed.

**Coroutine Class Definition:**
```abap
CLASS zcl_example_coroutine DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_coroutine_scope.
    TYPES: t_mara TYPE TABLE OF mara WITH DEFAULT KEY.
    TYPES: r_matnr TYPE RANGE OF mara-matnr.

    METHODS:
      constructor IMPORTING iv_matnr TYPE r_matnr,
      get_materials RETURNING VALUE(rt_materials) TYPE t_mara.
  PRIVATE SECTION.
    DATA: mt_materials TYPE t_mara,
          mr_matnr TYPE r_matnr.
ENDCLASS.
```

**Coroutine Implementation:**
```abap
CLASS zcl_example_coroutine IMPLEMENTATION.
  METHOD constructor.
    me->mr_matnr = iv_matnr.
  ENDMETHOD.

  METHOD zif_coroutine_scope~launch.
    SELECT * FROM mara INTO TABLE me->mt_materials WHERE matnr IN me->mr_matnr.
  ENDMETHOD.

  METHOD get_materials.
    rt_materials = me->mt_materials.
  ENDMETHOD.
ENDCLASS.
```

**Main Program:**
```abap
START-OF-SELECTION.
  DATA: lo_task TYPE REF TO zif_coroutine_task,
        lo_example_work TYPE REF TO zcl_example_coroutine,
        lt_materials TYPE zcl_example_coroutine=>t_mara.

  " Create an instance of the coroutine class
  lo_example_work = NEW zcl_example_coroutine( iv_matnr = VALUE #( ) ).

  " Start the coroutine
  lo_task = zcl_coroutine_manager=>run( lo_example_work ).

  " Perform other operations
  " ...

  " Retrieve results from the coroutine
  lo_example_work ?= lo_task->await( ).
  lt_materials = lo_example_work->get_materials( ).

  " Display results
  LOOP AT lt_materials INTO DATA(ls_material).
    WRITE: / ls_material-matnr, ls_material-meins.
  ENDLOOP.
```

#### Background Processing with Coroutines
This example illustrates how to use a coroutine for background processing tasks, such as sending an email. The coroutine performs the email sending operation asynchronously, allowing the main program to continue executing without waiting for the email process to complete.

**Coroutine Class Definition:**
```abap
CLASS zcl_example_coroutine DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_coroutine_scope.
    METHODS: 
      constructor IMPORTING iv_recipient TYPE bcs_address,
      send_email.
  PRIVATE SECTION.
    DATA: recipient TYPE bcs_address.
ENDCLASS.
```

**Coroutine Implementation:**
```abap
CLASS zcl_example_coroutine IMPLEMENTATION.
  METHOD constructor.
    me->recipient = iv_recipient.
  ENDMETHOD.

  METHOD zif_coroutine_scope~launch.
    send_email( ).
  ENDMETHOD.

  METHOD send_email.
    DATA: lo_msg TYPE REF TO cl_bcs_message,
          lt_tstc TYPE TABLE OF tstc.

    SELECT * FROM tstc INTO TABLE lt_tstc.

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
```

**Main Program:**
```abap
START-OF-SELECTION.
  DATA: lo_task TYPE REF TO zif_coroutine_task,
        lo_example_work TYPE REF TO zcl_example_coroutine.

  " Create an instance of the coroutine class
  lo_example_work = NEW zcl_example_coroutine( iv_recipient = 'furkan51cosgun@gmail.com' ).

  " Start the coroutine
  lo_task = zcl_coroutine_manager=>run( lo_example_work ).
```

Feel free to customize the code and examples to fit your specific needs.

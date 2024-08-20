*&---------------------------------------------------------------------*
*& Report zcoroutines4abap_demo
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcoroutines4abap_demo1.

CLASS zcl_example_coroutine DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_coroutine_scope.
    TYPES:t_mara TYPE TABLE OF mara WITH DEFAULT KEY.
    TYPES:r_matnr TYPE RANGE OF mara-matnr.

    METHODS:
      constructor
        IMPORTING
          ir_matnr TYPE r_matnr.
    METHODS:
      get_materials
        RETURNING VALUE(rt_materials) TYPE t_mara.
  PRIVATE SECTION.
    DATA:
      mt_materials TYPE t_mara,
      mr_matnr     TYPE r_matnr.
ENDCLASS.

CLASS zcl_example_coroutine IMPLEMENTATION.
  METHOD constructor.
    me->mr_matnr = ir_matnr.
  ENDMETHOD.
  METHOD zif_coroutine_scope~launch.
    SELECT * FROM mara INTO TABLE me->mt_materials WHERE matnr IN me->mr_matnr.
  ENDMETHOD.
  METHOD get_materials.
    rt_materials = me->mt_materials.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  DATA: lo_task         TYPE REF TO zif_coroutine_task,
        lo_example_work TYPE REF TO zcl_example_coroutine,
        lt_materials    TYPE zcl_example_coroutine=>t_mara.

  " Create an instance of the coroutine class
  lo_example_work = NEW zcl_example_coroutine( ir_matnr = VALUE #( ) ).

  " Start the coroutine
  lo_task = zcl_coroutine_manager=>run( lo_example_work ).

  " Other operations can be performed here
  " ...

  " Retrieve the results from the coroutine
  lo_example_work ?= lo_task->await( ).
  lt_materials = lo_example_work->get_materials( ).

  " Print the results
  LOOP AT lt_materials INTO DATA(ls_material).
    WRITE: / ls_material-matnr, ls_material-meins.
  ENDLOOP.

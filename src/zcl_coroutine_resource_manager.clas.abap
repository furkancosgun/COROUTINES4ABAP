CLASS zcl_coroutine_resource_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          runner_funcname TYPE funcname.
    INTERFACES:zif_coroutine_resource_manager.
    ALIASES:is_available FOR zif_coroutine_resource_manager~is_available.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:runner_funcname TYPE funcname.
ENDCLASS.



CLASS zcl_coroutine_resource_manager IMPLEMENTATION.
  METHOD:constructor.
    me->runner_funcname = runner_funcname.
  ENDMETHOD.
  METHOD is_available.
    CALL FUNCTION 'SPBT_PARALLEL_PROCESSING'
      EXPORTING
        group_name          = space
        rfc_function_module = me->runner_funcname
      EXCEPTIONS
        resource_failure    = 1.
    r_boolean = boolc( sy-subrc = 0 ).
  ENDMETHOD.
ENDCLASS.

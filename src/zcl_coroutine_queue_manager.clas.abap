CLASS zcl_coroutine_queue_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          resource_manager TYPE REF TO zif_coroutine_resource_manager
          runner_funcname  TYPE funcname.

    METHODS:
      end_of_task
        IMPORTING
          p_task TYPE clike.

    INTERFACES:zif_coroutine_queue_manager.
    ALIASES:add_to_queue       FOR zif_coroutine_queue_manager~add_to_queue.
    ALIASES:process_by_scope_id FOR zif_coroutine_queue_manager~process_by_scope_id.
    ALIASES:get_by_scope_id    FOR zif_coroutine_queue_manager~get_by_scope_id.
    ALIASES:is_task_completed  FOR zif_coroutine_queue_manager~is_task_completed.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      resource_manager TYPE REF TO zif_coroutine_resource_manager,
      coroutine_queue  TYPE HASHED TABLE OF zif_coroutine_queue_manager=>ty_coroutine_queue WITH UNIQUE KEY scope_id,
      runner_funcname  TYPE funcname.

    METHODS:
      run_in_foreground
        IMPORTING
          queue_object TYPE REF TO zif_coroutine_queue_manager=>ty_coroutine_queue.
    METHODS:
      run_in_background
        IMPORTING
          queue_object TYPE REF TO zif_coroutine_queue_manager=>ty_coroutine_queue.

ENDCLASS.



CLASS zcl_coroutine_queue_manager IMPLEMENTATION.
  METHOD:constructor.
    me->resource_manager = resource_manager.
    me->runner_funcname  = runner_funcname.
  ENDMETHOD.

  METHOD add_to_queue.
    INSERT VALUE #( scope_id        = scope_id
                    coroutine_scope = coroutine_scope
                    state           = zif_coroutine_queue_manager=>c_pending ) INTO TABLE coroutine_queue.
  ENDMETHOD.

  METHOD is_task_completed.
    READ TABLE me->coroutine_queue WITH KEY scope_id = scope_id
                                            state    = zif_coroutine_queue_manager=>c_completed
                                            TRANSPORTING NO FIELDS.
    r_boolean = boolc( sy-subrc EQ 0 ).
  ENDMETHOD.

  METHOD:get_by_scope_id.
    READ TABLE me->coroutine_queue WITH KEY scope_id = scope_id
                                            state    = zif_coroutine_queue_manager=>c_completed
                                            INTO r_queue.
  ENDMETHOD.

  METHOD process_by_scope_id.
    READ TABLE me->coroutine_queue WITH KEY scope_id = scope_id
                                            state    = zif_coroutine_queue_manager=>c_pending
                                            REFERENCE INTO DATA(queue_object).

    queue_object->state = zif_coroutine_queue_manager=>c_processing.
    IF me->resource_manager->is_available( ).
      me->run_in_background( queue_object ).
    ELSE.
      me->run_in_foreground( queue_object ).
    ENDIF.
  ENDMETHOD.

  METHOD:end_of_task.
    READ TABLE me->coroutine_queue REFERENCE INTO DATA(queue_object) WITH KEY scope_id = p_task.

    DATA: serialized_coroutine_object TYPE xml_strng.

    RECEIVE RESULTS FROM FUNCTION me->runner_funcname
      IMPORTING
        e_serilized_coroutine_object = serialized_coroutine_object
      EXCEPTIONS
        communication_failure = 1
        system_failure = 2
        OTHERS = 3.
    IF sy-subrc NE 0.
      run_in_foreground( queue_object ).
    ELSE.
      queue_object->state           = zif_coroutine_queue_manager=>c_completed.
      queue_object->coroutine_scope = zcl_coroutine_serializer=>deserialize( serialized_coroutine_object ).
    ENDIF.
  ENDMETHOD.

  METHOD:run_in_foreground.
    queue_object->coroutine_scope->launch( ).
    queue_object->state = zif_coroutine_queue_manager=>c_completed.
  ENDMETHOD.

  METHOD:run_in_background.
    CALL FUNCTION me->runner_funcname
      STARTING NEW TASK queue_object->scope_id
      DESTINATION IN GROUP DEFAULT
      CALLING end_of_task ON END OF TASK
      EXPORTING
        i_serilized_coroutine_object = zcl_coroutine_serializer=>serialize( queue_object->coroutine_scope )
      EXCEPTIONS
        communication_failure        = 1
        resource_failure             = 2
        system_failure               = 3
        OTHERS                       = 4.
    IF sy-subrc NE 0.
      me->run_in_foreground( queue_object ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

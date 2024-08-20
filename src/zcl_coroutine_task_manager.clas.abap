CLASS zcl_coroutine_task_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          queue_manager TYPE REF TO zif_coroutine_queue_manager
          scope_id      TYPE string.

    INTERFACES:zif_coroutine_task.
    ALIASES:await FOR zif_coroutine_task~await.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA:queue_manager TYPE REF TO zif_coroutine_queue_manager.
    DATA:scope_id TYPE string.
ENDCLASS.



CLASS zcl_coroutine_task_manager IMPLEMENTATION.
  METHOD constructor.
    me->queue_manager = queue_manager.
    me->scope_id      = scope_id.
  ENDMETHOD.

  METHOD await.
    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->queue_manager->is_task_completed( me->scope_id ).
    ro_result = me->queue_manager->get_by_scope_id( me->scope_id )-coroutine_scope.
  ENDMETHOD.
ENDCLASS.

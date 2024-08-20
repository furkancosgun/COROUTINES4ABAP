INTERFACE zif_coroutine_queue_manager
  PUBLIC .
  TYPES:ty_coroutine_state TYPE char10.

  CONSTANTS:
    c_pending    TYPE ty_coroutine_state VALUE 'PENDING',
    c_processing TYPE ty_coroutine_state VALUE 'PROCESSING',
    c_completed  TYPE ty_coroutine_state VALUE 'COMPLETED'.

  TYPES:BEGIN OF ty_coroutine_queue,
          scope_id        TYPE string,
          coroutine_scope TYPE REF TO zif_coroutine_scope,
          state           TYPE ty_coroutine_state,
        END OF ty_coroutine_queue.

  METHODS:
    add_to_queue
      IMPORTING
        scope_id        TYPE string
        coroutine_scope TYPE REF TO zif_coroutine_scope.
  METHODS:
    process_by_scope_id
      IMPORTING
        scope_id TYPE string.
  METHODS:
    get_by_scope_id
      IMPORTING
        scope_id       TYPE string
      RETURNING
        VALUE(r_queue) TYPE ty_coroutine_queue.
  METHODS:
    is_task_completed
      IMPORTING
        scope_id         TYPE string
      RETURNING
        VALUE(r_boolean) TYPE boolean.

ENDINTERFACE.

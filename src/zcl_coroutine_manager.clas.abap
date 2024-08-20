CLASS zcl_coroutine_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    CLASS-METHODS:
      class_constructor.

    CLASS-METHODS:
      run
        IMPORTING
          coroutine_scope TYPE REF TO zif_coroutine_scope
        RETURNING
          VALUE(ro_task)  TYPE REF TO zif_coroutine_task.

  PRIVATE SECTION.
    CONSTANTS: mc_runner_funcname TYPE funcname VALUE 'ZCOROUTINE_FM_TASK_RUNNER'.

    CLASS-DATA:
      resource_manager TYPE REF TO zif_coroutine_resource_manager,
      queue_manager    TYPE REF TO zif_coroutine_queue_manager.

    CLASS-METHODS:
      create_task_manager
        IMPORTING
          scope_id               TYPE string
        RETURNING
          VALUE(ro_task_manager) TYPE REF TO zcl_coroutine_task_manager.

    CLASS-METHODS:
      generate_scope_id
        RETURNING
          VALUE(r_uuid) TYPE string.
ENDCLASS.

CLASS zcl_coroutine_manager IMPLEMENTATION.
  METHOD class_constructor.
    resource_manager = NEW zcl_coroutine_resource_manager( runner_funcname = mc_runner_funcname ).
    queue_manager = NEW zcl_coroutine_queue_manager( resource_manager = resource_manager runner_funcname = mc_runner_funcname ).
  ENDMETHOD.

  METHOD run.
    DATA(scope_id) = generate_scope_id( ).
    queue_manager->add_to_queue( scope_id = scope_id coroutine_scope = coroutine_scope ).
    queue_manager->process_by_scope_id( scope_id ).
    ro_task = create_task_manager( scope_id = scope_id ).
  ENDMETHOD.

  METHOD create_task_manager.
    ro_task_manager = NEW zcl_coroutine_task_manager( queue_manager = queue_manager scope_id = scope_id ).
  ENDMETHOD.

  METHOD:generate_scope_id.
    DATA(system_uuid) = cl_uuid_factory=>create_system_uuid( ).
    DO.
      TRY.
          DATA(uuid_x16) = system_uuid->create_uuid_x16( ).
          EXIT.
        CATCH cx_uuid_error.
      ENDTRY.
    ENDDO.
    r_uuid = uuid_x16.
  ENDMETHOD.

ENDCLASS.

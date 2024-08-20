INTERFACE zif_coroutine_task
  PUBLIC .

  METHODS:
    await
      RETURNING
        VALUE(ro_result) TYPE REF TO zif_coroutine_result.
ENDINTERFACE.

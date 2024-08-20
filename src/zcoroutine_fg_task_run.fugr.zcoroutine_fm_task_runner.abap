FUNCTION ZCOROUTINE_FM_TASK_RUNNER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SERILIZED_COROUTINE_OBJECT) TYPE  XML_STRNG OPTIONAL
*"  EXPORTING
*"     VALUE(E_SERILIZED_COROUTINE_OBJECT) TYPE  XML_STRNG
*"----------------------------------------------------------------------

  DATA:coroutine_scope TYPE REF TO zif_coroutine_scope.
  TRY.
      coroutine_scope = zcl_coroutine_serializer=>deserialize( i_serilized_coroutine_object ).

      CHECK coroutine_scope IS BOUND.

      coroutine_scope->launch( ).

      e_serilized_coroutine_object = zcl_coroutine_serializer=>serialize( coroutine_scope ).
    CATCH cx_root INTO DATA(cx).
  ENDTRY.
ENDFUNCTION.

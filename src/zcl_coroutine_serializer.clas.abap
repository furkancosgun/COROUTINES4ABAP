CLASS zcl_coroutine_serializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS:
      deserialize
        IMPORTING
          serialized_object       TYPE xml_strng
        RETURNING
          VALUE(coroutine_object) TYPE REF TO zif_coroutine_scope.
    CLASS-METHODS:
      serialize
        IMPORTING
          coroutine_object         TYPE REF TO zif_coroutine_scope
        RETURNING
          VALUE(serialized_object) TYPE xml_strng.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_coroutine_serializer IMPLEMENTATION.
  METHOD deserialize.
    CALL TRANSFORMATION id SOURCE XML serialized_object RESULT oref = coroutine_object.
  ENDMETHOD.

  METHOD serialize.
    CALL TRANSFORMATION id SOURCE oref = coroutine_object RESULT XML serialized_object.
  ENDMETHOD.
ENDCLASS.

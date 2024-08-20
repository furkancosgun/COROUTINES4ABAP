INTERFACE zif_coroutine_resource_manager
  PUBLIC .
  METHODS:
    is_available
      RETURNING
        VALUE(r_boolean) TYPE boolean.
ENDINTERFACE.

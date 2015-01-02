defmodule Zr do
  @moduledoc ~S"""
  Zr is a result map designed to store the map of items, and varrious metadata fields returnable by dynamodb

  Currently the results returned from a dynamodb query are stored in items

  ## Example:

  ### single item
      %Zr{items: [%Zitem{attributes: %{}, data: "{}", key: {"bar", "foo"}, map: %{},
      opts: [attributes_to_get: []], table: "test_table"}]}

      zr = Zdb.get(item)
      [res] = zr.items

  TODO:  plan is to incorporate easy streaming of items 
  """
  @derive [Access]
  defstruct items: []
end

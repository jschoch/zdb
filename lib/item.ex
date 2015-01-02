defmodule Zitem do
  @moduledoc ~S"""

  Zitem is a struct for storing dynamodb rows.  

  ### Required fields
  
  key: {hash_key,range_key)

  ### Example

      map = %{key: "value"}
      attributes = [lastPostBy: "bob@bob.com"]
      item = %Zitem{key: {:bob,:email},table: "test_table",map: map,attributes: attributes}
  
      %Zitem{attributes: [], data: "{}", key: {:bar, :foo}, map: %{},
 opts: [attributes_to_get: []], table: "test_table"}
  
  ### magic

  :attributes are converted to dynamo attributes.  All dynamo attributes not matching [:key,:map,:data] are pulled out using Map.split and stored back after retrieval

  :map is converted to and from via Poison.encode!/decode!
  
  :opts are used for get_item and put_item options.  The options not needed for the action will be filtered out.  :attributes_to_get for example is not needed for put_item or Zdb.`put` and is removed for the the Zdb.put(item) call.
  """

  @derive [Access]
  defstruct table: "",
    key: {nil,nil}, 
    # TODO: do we need the item field?
    map: %{},
    opts: [attributes_to_get: []],
    data: "{}",
    attributes: []
end


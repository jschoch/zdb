defmodule Zitem do
  @derive [Access]
  defstruct table: "",
    key: {nil,nil}, 
    # TODO: do we need the item field?
    map: %{},
    opts: [attributes_to_get: []],
    data: "{}",
    attributes: []
end


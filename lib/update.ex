defmodule Zu do
  @moduledoc ~S"""
  
  structure for dynamodb update_item calls
  
  :attributes are [key: "value",...] where the key atoms are converted to strings for use in dynamodb.  Dynamodb value types are inferred via `Zdb.infer_keys\1` and `Zdb.infer_values\1`

  :action is the action :put || :delete || :add per `http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html`

  ## Example

  ### create item and setup
        iex(21)> item = %Zitem{key: {:bar,:foo},table: "test_table",map: %{foo: :foo}}
        %Zitem{attributes: [], data: "{}", key: {:bar, :foo}, map: %{foo: :foo},
        opts: [attributes_to_get: []], table: "test_table"}

        iex(22)>     Zdb.put(item)
        {:ok, []}

  ### simple update item

        iex(23)>     updates = %Zu{attributes: [lastPostBy: "bob@bobo.com"],action: :put}
        %Zu{action: :put, attributes: [lastPostBy: "bob@bobo.com"], opts: []}
        iex(24)>     res = Zdb.update(item,updates)
        []

  ### conditional update item

      iex(31)> updates = %Zu{attributes: [
      ...(31)>                     lastPostBy: "bob@bobo.com",
      ...(31)>                     data: Poison.encode!(%{foo: "foo"})],
      ...(31)>                   opts: [expected: [lastPostBy: "bob@bobo.com"]]}
      %Zu{action: :put,
      attributes: [lastPostBy: "bob@bobo.com", data: "{\"foo\":\"foo\"}"],
      opts: [expected: [lastPostBy: "bob@bobo.com"]]}
      iex(32)>     res = Zdb.update(item,updates)
      in_updates: [{"lastPostBy", {:s, "bob@bobo.com"}, :put}, {"data", {:s, "{\"foo\":\"foo\"}"}, :put}]
      []

  """
  defstruct attributes: [],opts: [],action: :put
end

defmodule ModTime do
  moduledoc "module to track typical timestamps for an item"
  use Timex
  defstruct created_at: Time.now, updated_at: Time.now, viewed_at: {0,0,0}
  defimpl Poison.Encoder, for: ModTime do
    defp t_to_l(map,key) when is_atom(key) do
      list = Map.fetch!(map,key) |> Tuple.to_list
      Map.put(map,key,list)
    end
    defp t_to_l(map,list) when is_list(list) do
      Enum.reduce(list,map,fn(key,map) ->
        t_to_l(map,key)
      end)
    end
    @doc "encode timestamp {a,b,c} to [a,b,c] and back"
    def encode(%ModTime{} = map,options) do
      map = t_to_l(map,[:created_at, :updated_at,:viewed_at]) 
      Poison.Encoder.Map.encode(map,options)
    end
  end
  defimpl Poison.Decoder, for: ModTime do
    defp a_to_l(map,list) when is_list(list) do
      Enum.reduce(list,map,fn(key,map) ->
        a_to_l(map,key)
      end)
    end
    defp a_to_l(map,key) do
      t = Map.fetch!(map,key) |> List.to_tuple
      Map.put(map,key,t)
    end
    def decode(map,options) do
      map = a_to_l(map,[:created_at, :updated_at, :viewed_at])
      struct(%ModTime{},map)
    end
  end
end

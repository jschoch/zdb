defmodule ModTime do
  use Timex
  defstruct created_at: Time.now, updated_at: Time.now
  defimpl Poison.Encoder, for: ModTime do
    defp t_to_l(map,key) do
      list = Map.fetch!(map,key) |> Tuple.to_list
      Map.put(map,key,list)
    end
    def encode(%ModTime{} = map,options) do
      map = t_to_l(map,:created_at)
      map = t_to_l(map,:updated_at)
      Poison.Encoder.Map.encode(map,options)
    end
  end
  defimpl Poison.Decoder, for: ModTime do
    defp a_to_l(map,key) do
      t = Map.fetch!(map,key) |> List.to_tuple
      Map.put(map,key,t)
    end
    def decode(map,options) do
      map = a_to_l(map,:created_at)
      map = a_to_l(map,:updated_at)
      struct(%ModTime{},map)
      #map
    end
  end
end

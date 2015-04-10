defmodule Zdb.Base.FK do
  @moduledoc " base implementation for Zdb struct as primary key "
  defmacro __using__(_) do
    quote do
      use Zdb.Base.PK
      def dk(%__MODULE__{fkey: fkey} = item) do
        {"#{fkey}_#{mod_name}",item.id}
      end
      def get(id) when is_binary(id) do
        raise "Can't derive key from id when using FK (foriegn key)"
      end
    end
  end
end

defmodule Zdb.Base.FK do
  @moduledoc " base implementation for Zdb struct using a foreign key for the hash key "
  defmacro __using__(_) do
    quote do
      use Zdb.Base.PK
      @doc " derive key from foreign key: fkey"
      def dk(%__MODULE__{fkey: fkey} = item) do
        {"#{fkey}_#{mod_name}",item.id}
      end
      def dk(fkey,id) do
        ensure_table_name
        {"#{fkey}_#{mod_name}",id}
      end
      def dk(_) do
        raise "Can't derive key from id when using FK (foriegn key)"
      end
      def get(fk,id) do
        key = dk(fk,id)
        {:ok, _get(@t_name,key)}
      end
    end
  end
end

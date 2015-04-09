defmodule Zdb.Base do
  defmacro __using__(_) do
    quote do
      use Ndecode
      def foo do
        IO.puts "FOO"
      end
      @doc "derive key if there exists a fkey in struct"
      def dk(%__MODULE__{fkey: nil} = item) do
        {item.hk,item.id}
      end
      @doc " derive key from self struct "
      def dk(%__MODULE__{fkey: fkey} = item) do
        {"#{fkey}_#{__MODULE__}",item.id}
      end
      def get!(%__MODULE__{} = item) do
        {:ok, item} = get(item)
        item
      end
      def get(%__MODULE__{} = item) do
        {:ok,item}
      end
      def get(id) when is_integer(id) or is_binary(id) do
        {:ok,%__MODULE__{id: id}}
      end
      def get!(id) when is_integer(id) or is_binary(id) do
        {:ok,item} = get(id)
        item
      end
      def get(id) do
        raise "only supporting %__MODULE__{} integer, and binary for get/1"
      end
      def get!(id) do
        raise "only supporting %__MODULE__{} integer, and binary for get/1"
      end
      def validate(%__MODULE__{} = item) do
        item
      end
      def validate!(%__MODULE__{} = item) do
        {:ok,item} = validate(item)
        item
      end
      @doc "puts a struct to DDB, if an entry exists with the same hk(ddb hash key) it will return the old value and a warning"
      def put(%__MODULE__{} = item) do
        key = dk(item)
        case Zdb.put(key,item) do
          {:ok,struct_s} when is_binary(struct_s) ->
            {:ok,Poison.decode!(struct_s,[keys: :atoms,as: __MODULE__])}
          good -> good
        end
      end
      def put!(%__MODULE__{} = item) do
        {:ok, item} = put(item)
        item
      end
      def fon(%__MODULE__{} = item) do
        item
      end
      def fon(id) when is_integer(id) or is_binary(id) do
        %__MODULE__{id: id}
      end
      def all() do
        []
      end
      def delete(%__MODULE__{} = item) do
        item
      end
      def delete!(%__MODULE__{} = item) do
        {:ok,item} = delete(item)
        item
      end
      def update(%__MODULE__{} = item) do
        item
      end
      def update!(%__MODULE__{} = item) do
        {:ok,item} = update(item)
        item
      end

      #def validate(%__MODULE__{} = item) do
      #  item
      #end

    end 
  end
end

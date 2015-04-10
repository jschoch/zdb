defmodule Zdb.Base.PK do
  @moduledoc " base implementation for Zdb struct as primary key "
  defmacro __using__(_) do
    quote do
      use Ndecode
      defstruct id: nil
      def puts_table_name do
        IO.puts "TNAME:\n\t#{inspect @t_name}"
      end
      def get_table_name do
        @t_name
      end
      def ensure_table_name do
        IO.puts "TNAME: #{inspect @t_name}"
        case @t_name do
          nil -> raise "You must define @t_name with the table name you want to use for any method using 'id' as the argument"
          _ -> true
        end
      end
      def mod_name do
        m = Atom.to_string( __MODULE__)
        case String.split(m,".") do
          [s] when is_binary(s) ->  s
          ["Elixir"|t] -> Enum.join(t,".")
          doh -> raise "HORROR! #{doh}"
        end
      end
      @doc "derive key from self"
      def dk(%__MODULE__{} = item) do
        key = {mod_name,item.id}
      end
      def dk(id) when is_binary(id) do
        ensure_table_name
        {mod_name,id} 
      end
      def get!(%__MODULE__{} = item) do
        {:ok, item} = get(item)
        item
      end
      def get(%__MODULE__{} = item) do
        key = dk(item)
        r = _get(item.table,key) 
        {:ok,r}      
      end
      def get(id) when is_binary(id) do
        key = dk(id)
        r = _get(@t_name,key)
        {:ok,r}
      end
      def _get(table,key) do
        r = nil
        case Zdb.get(table,key,[]) do
          nil -> nil
          struct_s when is_binary(struct_s) -> got = Poison.decode!(struct_s,[keys: :atoms,as: __MODULE__])
          doh -> raise "HORROR #{inspect doh}\nitem: #{inspect key}"
        end
      end
      def get!(id) when is_binary(id) do
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
          other -> other 
        end
      end
      def put!(%__MODULE__{} = item) do
        {:ok, item} = put(item)
        item
      end
      def fon(%__MODULE__{} = item) do
        item
      end
      def fon(id) when is_binary(id) do
        %__MODULE__{id: id}
      end
      def all() do
        {hk,rk} = dk(%__MODULE__{})
        qf = []
        q = %Zq{table: @t_name,kc: [{"hk",:eq,hk}],qf: qf} 
        raise "reimplement q to return raw items to be encoded to structs"
        case Zdb.q(q) do
          %{items: items} -> {:ok,items}
          doh -> raise "no items #{inspect doh, pretty: true}"
        end
      end
      def all! do
        {:ok, list} = all
        list
      end
      def delete(%__MODULE__{} = item) do
        key = dk(item)
        case Zdb.delete(item.table,key) do
          :ok -> {:ok,nil}
          {:ok,struct_s} -> 
            {:ok,Poison.decode!(struct_s,[keys: :atoms,as: __MODULE__])}
          {:error,:not_found} -> 
            Logger.debug "delete #{inspect item} not found"
            {:error,:not_found}
          {:error,e} ->
            raise "Delete Errror for item: #{inspect item}\n\n#{inspect e}"
        end
      end
      def delete!(%__MODULE__{} = item) do
        {:ok, old_item} = delete(item)
        nil
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
      defoverridable [dk: 1]
    end 
  end
end

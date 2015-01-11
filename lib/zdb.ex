defmodule Zc do
  @moduledoc """
  record for erlcloud aws_config()
  
  ## Example

  aws_config(ddb_port: 9001)
  """
  require Record
  Record.defrecord :aws_config, Record.extract(:aws_config,from_lib: "erlcloud/include/erlcloud_aws.hrl")
end
defmodule Zdb do
  defstruct table: "test_table"
  require Zc
  @doc ~S"""
  creates a table.  interpolates mix env for you: 
  table_name = #{Mix.env}_#{table_name}
  
  ## Example
    Zdb.create(table_name)

  """
  use Timex
  def create(name) do
    create(name,1,1)
  end
  @doc ~S"""
  creates a table.  interpolates mix env: table_name = "#{Mix.env}_#{table_name}"
  currently forces hash key and range key values for use with `Zitem`
  ## Example:
    Zdb.create(table_name,read_units,write_units)


  """
  def create(name,read_units,write_units,opts \\[]) do
    attrDefs = [{"hk",:s},{"rk",:s}]
    keySchema = {"hk","rk"}
    name = "#{Mix.env}_#{name}"
    :erlcloud_ddb2.create_table(name,attrDefs,keySchema,read_units,write_units,opts,config())
  end
  @doc ~S"""

  describes a ddb table using env prefixed table name

  ## Example
        Zdb.describe("test_table")

        {:ddb2_table_description, [{"hk", :s}, {"rk", :s}], 1420207158.875, 1,
        {"hk", "rk"}, :undefined, :undefined,
        {:ddb2_provisioned_throughput_description, :undefined, :undefined, 0, 1, 1},
        "dev_test_table", 36, :active}

  """
  def describe(table) do
    table = "#{Mix.env}_#{table}"
     case :erlcloud_ddb2.describe_table(table,[],config()) do
        {:ok,d} -> d
        {:error,e} -> IO.puts "describe error #{inspect e}"
      end
  end
  @doc ~S"""
  deletes the table by name, optional value to not raise on failure

  ## Example: 

        Zdb.delete_table("test_table")
        :ok


  ### run 2nd time 

      Zdb.delete_table("test_table")

        ** (RuntimeError) Delete table: test_table failed: {"ResourceNotFoundException", ""}.
        Tables available {:ok, ["Thread", "dev_play_table", "test_table"]}
        (zdb) lib/zdb.ex:29: Zdb.delete_table/2

  ### run with :no_raise

      iex(66)> Zdb.delete_table("test_table",:no_raise)

        WARNING: Delete table: test_table failed: :no_raise flag used
        :error

  """
  def delete_table(name,r \\:ok) do
    table = "#{Mix.env}_#{name}"
    case :erlcloud_ddb2.delete_table(table,[],config()) do
      {:ok,description} -> :ok #IO.puts "Table #{name} deleted\n\tDetails: #{inspect description}"
      {:error,e} when r == :no_raise -> IO.puts "WARNING: Delete table: #{name} failed: :no_raise flag used"
        :error
      {:error,e} -> raise "Delete table: #{name} failed: #{inspect e}. \n\tTables available #{inspect Zdb.list}"
    end 
  end
  @doc ~S"""
  prints your default_config()

  """
  def print_config() do
    env = Application.get_all_env(:zdb) |> Enum.into(%{})
    c = [ddb_host: env.ddb_host,
      ddb_port: env.ddb_port,
      ddb_scheme: env.ddb_scheme,
      access_key_id: env.ddb_key,
      secret_access_key: env.ddb_skey]
    Enum.into(c,%{})
  end
  @doc ~S"""
  grabs the current config based on your Mix.env
  """
  def config() do
    env = Application.get_all_env(:zdb) |> Enum.into(%{})
    Zc.aws_config(ddb_host: env.ddb_host,ddb_port: env.ddb_port,ddb_scheme: env.ddb_scheme,access_key_id: env.ddb_key,secret_access_key: env.ddb_skey)
  end
  @doc ~S"""
  lists available tables based on your Mix.env
  """
  def list() do
    :erlcloud_ddb2.list_tables([],config())
    
  end
  @doc ~S"""
  TODO: not sure I need this
  """
  def t(table_name) do
    %Zdb{table: table_name}
  end
  @doc ~S"""
  get_item returns: `Zr`

  ## Example: 
      iex(1)> item = %Zitem{key: {:bar,:foo},table: "test_table"}
      %Zitem{attributes: [], data: "{}", key: {:bar, :foo}, map: %{},
      opts: [attributes_to_get: []], table: "test_table"}
  
      iex(9)> Zdb.get("test_table","bar","foo")
      %Zr{items: [%Zitem{attributes: %{}, data: "{}", key: {"bar", "foo"}, map: %{},
      opts: [attributes_to_get: []], table: "test_table"}]}
  """
  def get(table,hash_key,range_key) when is_binary(hash_key)  do
    key = [
            {"hk",hash_key},
            {"rk",range_key}
          ]
    _get(table,key)
  end
  #def get(%Zdb{} = z,%Key{} = key) do
    #k = Map.from_struct(key)
          #|> Map.to_list
          ##|> Enum.map(fn({k,v}) -> {Atom.to_string(k),v} end) 
    #_get(z.table,k)
  #end
  @doc ~S"""
  get_item returns: `Zr`
  ## Example:
      iex(1)> item = %Zitem{key: {:bar,:foo},table: "test_table"}
      %Zitem{attributes: [], data: "{}", key: {:bar, :foo}, map: %{},
      opts: [attributes_to_get: []], table: "test_table"}

      iex(6)> Zdb.get(item)
    %Zr{items: [%Zitem{attributes: %{}, data: "{}", key: {"bar", "foo"}, map: %{},
       opts: [attributes_to_get: []], table: "test_table"}]}

  """
  def get(%Zitem{} = item) do
    key = parse_key(item)
    _get(item.table,key)
  end
  defp _get(table_name,key,opts \\[]) do
    table = "#{Mix.env}_#{table_name}"
    case :erlcloud_ddb2.get_item(table,key,opts,config()) do
      {:ok, ddb} ->
        #map = make_map(list)
        #data = Poison.decode!(map.data,keys: :atoms!)
        item = ddb_to_zitem(ddb,table_name)
        %Zr{items: [item]}
      {:error,e} -> raise "Zdb.get error: #{inspect e}\n\ttable: #{inspect table}\n\tkey: #{inspect key}\n\topts: #{inspect opts}\n\tconfig: #{inspect config()}"
    end
  end
  @doc false
  def item_key_to_strings({k,v}) when is_binary(k) do
    {k,v}
  end
  @doc false
  def item_key_to_strings({k,v}) when is_atom(k) and is_atom(v) do
    {Atom.to_string(k),Atom.to_string(v)}
  end
  @decap_reg ~r/^(?<s>[A-Z])/
  #def decap(string) do
    #case String.match?(string,@decap_reg) do
      #true -> 
        #IO.puts "WARNING: Zdb doesn't like cap'ed atoms, forcing downcase of first char"
        #[s] = Regex.run(@decap_reg,string,capture: :first)
        #[_|new] = String.to_char_list(string)
        #Enum.join([String.downcase(s),List.to_string(new)])
      #false -> string
    #end
  #end
  def decap(""), do: ""
  
  @doc ~S"""
    decapitalizes first letter of a string
    
      ## Example:

    iex(10)> Zdb.decap("Foo")
    WARNING: please don't use caps in key names!!! "Foo"
    "foo"
  """

  def decap(s) do
    case String.match?(s,@decap_reg) do
      true -> IO.puts "WARNING: please don't use caps in key names!!! #{inspect s}"
        {first, rest} = String.next_grapheme(s)
        String.downcase(first) <> rest
      false -> s
    end
  end 
  def keys_to_strings(list) when is_list(list) or is_map(list) do
  #def keys_to_strings(list) when is_list(list)  do
    # maps don't like caps on atoms
    Enum.map(list,fn({k,v})-> keys_to_strings(k,v) end)
  end
  def keys_to_strings(huh) do
    IO.puts "WTF: #{inspect huh}"
  end
  def keys_to_strings(k,v) do
    case k do
      k when is_atom(k) -> 
        new_key = Atom.to_string(k) |> decap
        {new_key,v}
      _ -> {k,v}
    end
  end
  @doc ~S"""
  dynamo put_item, requires `Zitem`

  ## Example: 

        iex(11)> item = %Zitem{key: {:bar,:foo},table: "test_table"}

        %Zitem{attributes: [], data: "{}", key: {:bar, :foo}, map: %{},
         opts: [attributes_to_get: []], table: "test_table"}


        iex(12)>     Zdb.put(item)

        {:ok, []}

  """
  def put(%Zitem{} = item) do
    {hk,rk} = item.key
    #TODO: encode item.data here, not in call
    i = [table: item.table,hk: hk, rk: rk,data: item.data,map: Poison.encode!(item.map)]
    m = Dict.merge(i,item.attributes)
    i =  keys_to_strings(m)
    #i = keys_to_strings(i)
    opts = Enum.filter(item.opts,fn({k,v}) -> k != :attributes_to_get end)
    {:ok,[]} = _put(item.table,i,opts) 
    {:ok,item}
  end

  defp _put(table_name,item,opts \\[return_values: :all_old]) do
    table = "#{Mix.env}_#{table_name}"
    case :erlcloud_ddb2.put_item(table,item,opts,config()) do
      {:ok, ret} when ret == [] ->
        {:ok,[]}
      {:ok, ret} ->
        IO.puts "WARNING: put overwrote an existing item #{inspect ret}"
        {:ok,[]}
      {:error,e} -> raise "Zdb.put error: #{inspect e} \n\t table: #{inspect table_name}\n\t item #{inspect item}\n\t opts: #{inspect opts}"
    end
  end
  def parse_key(item) do
    {hk,rk} = item_key_to_strings(item.key)
    key = infer_keys([hk: hk,rk: rk])
  end
  def update(%Zitem{} = item,%Zu{} = updates) do
    key = parse_key(item)
    _update(item.table, key, updates) 
  end
  def _update(table_name, key,updates) do
    table = "#{Mix.env}_#{table_name}"
    converted_updates = infer_keys(updates.attributes)
    in_updates = Enum.map(converted_updates,fn({k,v}) -> {k,v,updates.action} end)
    IO.puts "in_updates: #{inspect in_updates}"
    opts = parse_update_opts(updates.opts)
    case :erlcloud_ddb2.update_item(table,key,in_updates,opts,config()) do
      {:ok,ret} -> ddb_to_zitem(ret,table_name)
      {:error,{"ConditionalCheckFailedException", ""}} -> 
        IO.puts "WARNING Zdb.update conditional check failed for key: #{inspect key}"
        :condition_check_failed
      {:error,e} -> raise "Zdb.get error: #{inspect e}\n\tconverted_updates= #{inspect in_updates}\n\ttable= #{inspect table}\n\tin_updates= #{inspect in_updates}\n\tkey= #{inspect key}\n\topts= #{inspect opts}\n\tconfig= #{inspect config()}"
    end
  end
  def parse_update_opts(opts) do
    case Dict.has_key?(opts,:expected) do
      true -> 
        # TODO: erlcloud doesn't seem to support multiple expected, is 
        # this a ddb limitation?
        [o] = infer_keys(opts[:expected])
        opts = Dict.put(opts,:expected,o)
      false -> opts 
    end
  end
  def infer_keys({key,value}) do
    case key do
      key when is_atom(key) -> k = Atom.to_string(key) |> decap
      key -> k = key
    end
    {k,infer_value({k,value})}
  end
  def infer_keys(list) when is_list(list) do
    Enum.map(list,fn(k) when is_tuple(k)  -> infer_keys(k) end)
  end
  def infer_value({k,v}) do
    case v do
      v when is_binary(v) -> {:s,v}
      v when is_number(v) -> {:n,v}
      v when is_list(v) -> {:l,v}
      v when is_map(v) -> {:s,Poison.encode!(v)}
      v when is_boolean(v) -> {:bool,v}
      finish -> "infer_value: unknown type for key: #{inspect k} value: #{inspect v}"
    end
  end
  ### TODO delete convert_updates, don't need them I dont' think
  #def convert_updates(tes) do
    #a = Enum.map(updates.attributes,fn(a) -> infer_keys(a) end)
    ##{a,updates.opts}
  #end
  ### end TODO
  def a_to_s(a) when is_atom(a) do
    Atom.to_string(a) |> decap
  end
  def a_to_s(a) do
    a
  end
  def parse_kc(list) when is_list(list) do
    Enum.map(list,fn(i) -> parse_kc(i) end)
  end
  def parse_kc({k,o,v}) do
    # Key, Operator, Value seems more readable, but erlcloud wants Key,Value, Operator
    k = a_to_s(k)
    v = a_to_s(v)
    {k,v,o} 
  end
  def parse_kc({k,o,a,b}) do
    # :foo, :between, :a and :b
    # tranlate for erlcloud
    k = a_to_s(k)
    a = infer_value({k,a})
    b = infer_value({k,b})
    {k,{a,b},o}
  end
  @doc ~S"""
  q(`Zr`)

  # TODO: sane API needs lots  of work, looking for comments
  ## Example
  
      Access all hash keys equal to "bob" and range keys that begin with "e".  First you must create a query filter, then you can match :eq | :ne | :le | :lt | :ge | :gt | :not_null | :null | :contains | :not_contains | :begins_with | :in | :between

      qf = {"thing",1,:gt}
      q = %Zq{table: "test_table",kc: [{"hk",:eq,:bob}],qf: qf}
      res = Zdb.q(q)


      qf = {"other_thing","foo",:eq}
      q = %Zq{table: "test_table",kc: [{"hk",:eq,:bob}],qf: qf}
      res = Zdb.q(q)

  """
  def q(%Zq{} = zq) do
    e_kc = parse_kc(zq.kc)
    opts = []
    case zq.qf != [] do
      true ->
        opts = parse_query_options(zq)
      false -> 
        IO.puts "warning no query filter #{inspect zq}"
    end
    _q(zq.table,e_kc,opts)
  end
  def _q(table_name,e_kc,opts) do
    table = "#{Mix.env}_#{table}"
    IO.puts ":erlcloud_ddb2.q(#{inspect table},#{inspect e_kc},#{inspect opts},Zdb.config)"
    case :erlcloud_ddb2.q(table,e_kc,opts,config()) do
      {:ok, r} when is_list(r) -> %Zr{items: list_to_zitems(r,table_name)}
      {:ok, r} -> raise "why is r not a list!!! #{inspect r}"
      {:error, e} -> raise "query error #{inspect e}\n\tkc = #{inspect e_kc}\n\ttable = #{inspect table}\n\topts = #{inspect opts}"
    end
  end
  def parse_query_options(zq) do
    opts = []
    case Map.has_key?(zq,:qf) do
      true -> opts = opts ++ [query_filter: zq.qf]
      false -> nil
    end
    #case Map.has_key?(zq,:fe) do
      #true -> 
        #opts = opts ++ [{:filter_expression, zq.fe} ]
        #opts = opts ++ [{:expression_attribute_values,zq.eav}]
      #false -> nil
    #end
    opts
  end
  def scan(name) when is_binary(name) do
    table = "#{Mix.env}_#{name}"
    case :erlcloud_ddb2.scan(table,[],config()) do
      {:ok, stuff} -> list_to_zitems(stuff,name)
      {:error, e} -> raise "scan error #{inspect e}\n\ttable: #{inspect name}"
    end
  end
  def scan(%Zs{} = zs) do
    raise "TODO: not done scan yet"
  end
  def delete(%Zitem{} = item) do
    table = "#{Mix.env}_#{item.table}"
    key = parse_key(item)
    opts = Enum.filter(item.opts,fn({k,v}) -> k != :attributes_to_get end)
    case :erlcloud_ddb2.delete_item(table,key,opts,config()) do
      {:ok, match} -> 
        IO.puts "delete_item result for item: #{inspect item}\n\t#{inspect match}"
        {:ok,ddb_to_zitem(match,item.table)}
      {:error, {"ResourceNotFoundException", "Requested resource not found"}} ->
        es = "Could not delete, item not found.  item.key #{inspect item.key}"
        IO.puts es
        {:error,es}
      {:error, e} -> 
        raise "Zdb.delete error: #{inspect e}\n\titem: #{inspect item}"
        #{:error,es}
    end  
  end
  def list_to_zitems(list,table) do
    Enum.map(list, fn(i) -> 
      ddb_to_zitem(i,table)
    end)
  end
  def ddb_to_zitem(ddb,table) do
    case make_map(ddb) do
      item when item == %{} -> 
        IO.puts "WARNING: empty result from make_map \n\t#{inspect ddb}"
        %Zitem{}
      item -> 
        item = Map.put(item,:table,table)
        item = Map.put(item,:key,{item.hk,item.rk})
        item = Map.drop(item,[:hk,:rk])
        case Map.has_key?(item,:map) do
          true -> 
            map = Poison.decode!(item.map,keys: :atoms!)
            item = Map.put(item,:map,map)
          false -> data = "{}"
        end
        {item,attributes} = Map.split(item,[:data,:key,:map,:table])
        item = Map.put(item,:attributes,attributes)
        #%Zitem{key: {item.hk,item.rk},map: item,table: table}
        struct(%Zitem{},item)
    end
  end
  def make_map(data) when is_list(data) do
    first = List.first(data)
    case first do
      i when is_list(i) -> make_map_list_of_lists(data)
      {k,v} -> make_map_list_of_kv(data)
      nil ->
        IO.puts "make_map: nothing to do here"
        %{}
      horror -> raise "Zdb.make_map the horror #{inspect horror}"
    end
  end
  def make_map_list_of_lists(data) do
    data = Enum.map(data,fn(item) ->
      item = Enum.map(item,fn({k,v}) ->
        {String.to_atom(k),v}
      end)
      Enum.into(item,%{})
    end)
  end
  def make_map_list_of_kv(data) do
    list = Enum.map(data,fn({k,v}) ->
      {String.to_atom(k),v}
    end)
    Enum.into(list,%{})
  end
  @doc ~S"""
  gets a time stamp from timex, format ISO in UTC
  ## Example

      iex(1)> Zdb.gts
      "2015-01-05T13:04:45+0000"
  """
  def gts do
    date = Date.local
    date = Date.universal(date)
    DateFormat.format!(date,"{ISO}")
  end
end


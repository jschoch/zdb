defmodule UB do
  @t_name "test_base_table"
  defstruct   table: @t_name,
    id: nil,
    test: "1",
    mod: %ModTime{}
  use Zdb.Base.PK
end
defmodule FK do
  @t_name "test_base_table"
  defstruct table: @t_name,
    id: nil,
    fkey: nil,
    attr: "1" 
  use Zdb.Base.FK
end

defmodule BAD do
  #defstruct yousuck: true
  use Zdb.Base.PK
end

defmodule UBTest do
  use ExUnit.Case
  use Ndecode
  def sl do
    :timer.sleep(200)
  end
  setup do
    if (Mix.env != :prod) do
      Zdb.delete_table("test_base_table",:no_raise)
      Zdb.create("test_base_table")
    end
    :ok
  end
  test "keys work" do
    ub = %UB{id: "1"}
    IO.inspect ub
    key = UB.dk(ub)
    assert {"UB",ub.id} == key
    %UB{} = UB.validate(ub)
    s = Poison.encode!(ub)
    decoded = Poison.decode!(s,[keys: :atoms, as: UB])
    assert match?(%ModTime{}, decoded.mod)
    assert ub == decoded
    id = "1"
    key = UB.dk(id)
    assert key == {"UB",ub.id}
    UB.puts_table_name
    t_name = UB.get_table_name
    assert t_name == "test_base_table"
    Logger.flush()
    sl
  end
  test "bad handled with the right errors" do
    b = %BAD{id: "1"}
    key = BAD.dk(b) 
    IO.puts "bad key: #{inspect key}"
    assert_raise RuntimeError, fn->
      key = BAD.dk(b.id)
    end
  end
  test "can put" do
    ub = %UB{id: "1"}
    {:ok,nil} = UB.put(ub)
    ub_t2 = Map.put(ub,:test,"2") 
    # overwrite with different test value
    {:ok,%UB{} = x} =UB.put(ub_t2)
    assert x != nil
    # Old value returned test should == "1"
    assert x.test == "1"
    # bit of a hack here
    assert ub == x
    ub = Map.put(ub,:hk,"UB")
    ub = %UB{id: "2"}
    {:ok,nil} = UB.put(ub)
    x = UB.put!(ub)
    assert match?(%UB{}, x)
    assert x.id == "2"
    Logger.flush()
    sl
  end
  test "can get" do
    ub = %UB{id: "1"}
    {:ok,nil} = UB.put(ub)
    {:ok,%UB{} = x} = UB.get(ub)
    assert x == ub
    y = UB.get!(ub)
    assert y == ub
    z = UB.get!(ub.id)
    assert z == ub
    a = UB.get!("doesn't exist anywhere")
    assert a == nil
  end
  test "can get with derived foreign key" do
    ub = %UB{id: "1"}
    fk = %FK{id: "1",fkey: ub.id}
    key = FK.dk(fk)
    assert key == {"1_FK", "1"}, "wrong key: got: #{inspect key}"
    key = FK.dk(ub.id,fk.id)
    assert key == {"1_FK", "1"}, "wrong key: got: #{inspect key}"
    nil = FK.put!(fk)
    IO.puts "Scan: \n#{inspect Zdb.scan(FK.get_table_name)}"
    {:ok,got} = FK.get(fk)
    assert got != nil,"got was nil"
    assert got.id == "1", "id should be 1, got: #{inspect got}"
    assert got.fkey == "1"
    assert got == fk
    assert_raise RuntimeError, fn->
      FK.get("1")
    end
  end
  test "can delete" do
    ub = %UB{id: "1"}
    {:ok,nil} = UB.put(ub)
    UB.delete(ub)
    x = UB.get!(ub.id) 
    assert x == nil
    UB.delete!(ub)
  end
  def ub_make_lots(count) do
    Enum.each(1..count,fn(i) ->
      UB.put(%UB{id: to_string(i)})
    end)
  end
  def fk_make_lots(count) do
    Enum.each(1..count,fn(i) ->
      FK.put(%FK{id: to_string(i),fkey: to_string(i)})
    end)
  end
  test "gets all" do
    ub_make_lots(3)
    fk_make_lots(2)
    {:ok,list} = UB.all
    IO.puts inspect list,pretty: true
    assert Enum.count(list) == 3, "wrong sized list #{inspect list, pretty: true}"
    {:ok,list} = FK.all("1")
    IO.puts inspect list,pretty: true
    assert Enum.count(list) == 1,"wrong sized list #{inspect list}"
    
    {:ok,list} = FK.all("2")
    IO.puts inspect list,pretty: true
    assert Enum.count(list) == 1,"wrong sized list #{inspect list}"

    assert false, "add real parsing of structs"
    assert false, "add pagination option"
    assert false, "make sure you can get results over single request limits"
  end
  test "the rest" do
    ub = %UB{id: "1"}
    UB.put!(ub)
    %UB{} =UB.update(ub)
    %UB{} =UB.fon(ub)
    %UB{} = UB.fon(ub.id)
    list = UB.all
  end
end

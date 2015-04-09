defmodule UB do
  defstruct hk: Atom.to_string( __MODULE__), 
    rk:  nil,
    table: "test_base_table",
    id: nil,
    fkey: nil,
    key: nil,
    test: "1",
    mod: %ModTime{}
  use Zdb.Base
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
  test "yup" do
    UB.foo
    assert true
    ub = %UB{id: "1"}
    IO.inspect ub
    key = UB.dk(ub)
    assert {"UB",ub.id} == key
    ub_with_fkey = Map.put(ub,:fkey,"3")
    from_fkey = UB.dk(ub_with_fkey)
    assert from_fkey == {"3_Elixir.UB", "1"}
    %UB{} = UB.validate(ub)
    s = Poison.encode!(ub)
    decoded = Poison.decode!(s,[keys: :atoms, as: UB])
    assert match?(%ModTime{}, decoded.mod)
    assert ub == decoded
    Logger.flush()
    sl
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
  end
  test "the rest" do
    ub = %UB{id: "1"}
    UB.put!(ub)
    %UB{} =UB.update(ub)
    {:ok,%UB{}} = UB.get(ub)
    %UB{} =UB.get!(ub)
    {:ok,%UB{}} = UB.get(ub.id)
    %UB{} = UB.get!(ub.id)
    %UB{} =UB.fon(ub)
    %UB{} = UB.fon(ub.id)
    list = UB.all
    %UB{} =UB.delete(ub)
    

  end
end

defmodule UB do
  defstruct hk: nil, rk: nil,table: "test_table",id: nil,mod: %ModTime{}
  use Zdb.Base
end


defmodule UBTest do
  use ExUnit.Case

  test "yup" do
    UB.foo
    assert true
    ub = %UB{id: 1}
    %UB{} = UB.validate(ub)
    %UB{} =UB.put(ub)
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

#  tests to familiarize with using erlcloud api
defmodule PlayTest do
  use ExUnit.Case
  #use Zdb.TH
  setup do
    Zdb.delete("Thread",:no_raise)
    :ok
  end
  test "complex create table" do
    {res,data} = Zdb.TH.e_create_table
    IO.inspect data
    assert res == :ok, "create failed with error: #{inspect data}"
  end
  test "put example" do
    Zdb.TH.e_create_table
    {res,data} = Zdb.TH.e_put
    assert res == :ok, "put failed with error: #{inspect data}"
  end
  test "delete example" do
    Zdb.TH.e_create_table
    Zdb.TH.e_put
    {res,data} = Zdb.TH.e_delete
    assert res == :ok, "delete failed with error: #{inspect data}"
  end
  test "query example" do
    Zdb.TH.e_create_table
    Zdb.TH.e_put
    {res,data} = Zdb.TH.e_q
    assert res == :ok, "query failed with error: #{inspect data}"
  end
  test "get example" do
    Zdb.TH.e_create_table
    Zdb.TH.e_put
    {res,data} = Zdb.TH.e_get
    assert res == :ok, "get failed with error: #{inspect data}"
    assert data != [], "get got an empty set"
  end
  test "update items" do
    Zdb.TH.e_create_table
    Zdb.TH.e_put
    {res,data} = Zdb.TH.e_update
    assert res == :ok, "update failed with error: #{inspect data}"
  end
end

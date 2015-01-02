defmodule PlayTest do
  use ExUnit.Case
  @table "play_table"
  setup do
    IO.puts "SETUP start"
    Zdb.delete(@table,:no_raise)
    Zdb.create(@table)
    #:timer.sleep(100)
    IO.puts "SETUP stop"
    :ok
  end
  test "playing with syntax" do
    # put a few items 
    a = [unf: "unf", snu: "snusnu"]
    item = %Zitem{hk: "bar",rk: "foo",table: @table,attributes: a}
    Zdb.put(item)
    item = %Zitem{hk: "bar",rk: "foo1",table: @table,attributes: a}
    Zdb.put(item)
    b = [bada: "bing", you: "there"]
    item = %Zitem{hk: "bar",rk: "foo2",table: @table,attributes: b}
    Zdb.put(item)

    # run a query to get a list back of all "bar"
         
  end
end

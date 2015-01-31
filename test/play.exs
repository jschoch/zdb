defmodule PlayTest do
  use ExUnit.Case
  require Logger
  @table "play_table"
  setup do
    IO.puts "SETUP start"
    Zdb.delete_table(@table,:no_raise)
    Zdb.create(@table)
    IO.puts "SETUP stop"
    :ok
  end
  test "playing with syntax" do
    # put a few items 
    #a = [unf: "unf", snu: "snusnu"]
    #item = %Zitem{hk: "bar",rk: "foo",table: @table,attributes: a}
    #Zdb.put(item)
    #item = %Zitem{hk: "bar",rk: "foo1",table: @table,attributes: a}
    #Zdb.put(item)
    #b = [bada: "bing", you: "there"]
    #item = %Zitem{hk: "bar",rk: "foo2",table: @table,attributes: b}
    #Zdb.put(item)

    # run a query to get a list back of all "bar"
         
  end
  @tag timeout: 2000000
  test "playing with streams" do
    gen_items = fn ->
      items = Enum.map(1..100000,fn(i)->
        i = Integer.to_string(i)
        %Zitem{key: {i,i},table: @table}
      end)
    end
    {time,items} = :timer.tc(gen_items)
    IO.puts "Time to create items: #{time}" 
    put_items = fn(items) ->
      stream = Stream.each(items,fn(i) ->
        Zdb.put(i)
      end )
      Enum.to_list(stream)
    end
    {time,res} = :timer.tc(put_items,[items])
    IO.puts "Time to put items: #{time}"
  end
  def worker do
    receive do
      {:ok,item} -> 
        Logger.info(inspect self())
        Zdb.put(item)
        worker
      {:close} -> Logger.info "shutting down"
    after 500 -> IO.puts "you got a problem"
    end
  end
  test "play with procs and streams" do
    procs = 4
    pids = Enum.map(0..procs,fn(i)->
      spawn(__MODULE__,:worker,[])
    end)
    items = Enum.map(1..100,fn(i)->
      i = Integer.to_string(i)
      %Zitem{key: {i,i},table: @table}
    end)
    Stream.cycle(pids)|> Stream.zip(items)|> Enum.map(fn({pid,item}) -> 
      send pid,{:ok,item}
    end)
    IO.puts "sleeping"
    :timer.sleep(2000)
    IO.puts "done sleeping, shutting down workers"
    Enum.each(pids,fn(pid) -> send pid,{:close} end)
    :timer.sleep(500)
  end
end

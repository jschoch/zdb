defmodule ZdbTest do
  use ExUnit.Case
  setup do
    IO.puts "SETUP start"
    Zdb.delete_table("test_table",:no_raise)
    Zdb.create("test_table")
    #:timer.sleep(100)
    IO.puts "SETUP stop"
    :ok
  end
  test "env works" do
    case Mix.env do
      :test -> c = Zdb.print_config
        assert (c.ddb_port == 8000)
      :dev -> c = Zdb.print_config
        assert (c.ddb_port == 8000)
    end
  end
  test "table struct works" do
    zconf = Zdb.t("test_table")
    assert match? %Zdb{}, zconf
  end
  test "result struct works" do
    item = %Zitem{key: {:bar,:foo},table: "test_table"}
    Zdb.put(item)
    #res = Zdb.get(item)
    zr = Zdb.get(item)
    assert match? %Zr{}, zr
    
    # Get by item
    #zr = Zdb.get(item)
    #[res] = zr.items
    [res] = Zdb.get(item).items
    key = res.key
    assert key ==  {"bar","foo"}
  end
  test "simple get works" do
    item = %Zitem{key: {:bar,:foo},table: "test_table"}
    Zdb.put(item)
    zr = Zdb.get(item)
    [i] = zr.items
    assert i.key == {"bar","foo"}
  end
  test "put and get map works" do
    item = %Zitem{key: {:bar,:foo},table: "test_table",map: %{key: "value"}}
    Zdb.put(item)
    [new_item] = Zdb.get(item).items 
    map = new_item.map
    IO.puts "map: #{inspect map}"
    assert is_map(map)
    assert map.key == "value"
  end
  test "delete works" do
    item = %Zitem{key: {:bar,:foo},table: "test_table",map: %{key: "value"}}
    Zdb.put(item)
    res = Zdb.delete(item)
    assert res == []
  end
  test "ddb_to_zitem works properly" do
    ddb = [{"data", "{}"}, {"map", "{\"key\":\"value\"}"}, {"hk", "bar"}, {"rk", "foo"},{"lastPostBy", "bob@bob.com"}]
    item = Zdb.ddb_to_zitem(ddb,"foo")
    assert item.map.key == "value"
    assert item.attributes.lastPostBy == "bob@bob.com"
  end
  test "put with attributes works correctly" do
    map = %{key: "value"}
    attributes = [lastPostBy: "bob@bob.com"]
    item = %Zitem{key: {:bob,:email},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
    [i] = Zdb.get(item).items
    assert(match?(%Zitem{},i))
    assert i.attributes.lastPostBy ==  "bob@bob.com"
  end
  test "infer keys works" do
    ui = [lastPostBy: "fred@example.com"]
    updates = %Zu{attributes: ui}
    res = Zdb.infer_keys(List.first ui)
    assert res == {"lastPostBy", {:s, "fred@example.com"}}
  end
  test "infer_keys(list) works" do
    ui = [lastPostBy: "fred@example.com"]
    opts = [:attributes_to_get,["foo","bar"]]
    updates = %Zu{attributes: ui, opts: opts}
    keys = Zdb.infer_keys(updates.attributes)
    assert keys == [{"lastPostBy", {:s, "fred@example.com"}}]
  end
  test "update item works" do
    item = %Zitem{key: {:bar,:foo},table: "test_table",map: %{foo: :foo}}
    Zdb.put(item)
    updates = %Zu{attributes: [lastPostBy: "bob@bobo.com"],action: :put}
    res = Zdb.update(item,updates)
    IO.puts "Update return: #{inspect res}"
    #[new] = Zdb.get(item)
    [new_item] = Zdb.get(item).items
    assert new_item.table == "test_table", "table was no good item: #{inspect new_item}"
    assert new_item.map == %{foo: "foo"}
  end
  test "update item with conditional works" do
    map = %{key: "value"}
    attributes = [lastPostBy: "bob@bob.com"]
    item = %Zitem{key: {:bob,:email},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
    updates = %Zu{attributes: [lastPostBy: "bob@bobo.com"],action: :put,
                  opts: [expected: [lastPostBy: "bob@bob.com"],
                    return_values: :all_new ]
              } 
    res = Zdb.update(item,updates)
    assert res == [{"map", "{\"key\":\"value\"}"}, {"data", "{}"}, {"hk", "bob"},
            {"table", "test_table"}, {"lastPostBy", "bob@bobo.com"},
            {"rk", "email"}]
    updates = %Zu{attributes: [
                    lastPostBy: "bob@bobo.com",
                    data: Poison.encode!(%{foo: "foo"})],
                  opts: [expected: [lastPostBy: "bob@bobo.com"]]}
    res = Zdb.update(item,updates)
  end
  test "put and get struct works" do
    assert false, "get/put struct TODO"
  end
  test "scan(name) works" do
    item = %Zitem{key: {:foo,:bar},table: "test_table"}
    Zdb.put(item)
    res = Zdb.scan("test_table")
    IO.puts "scan: #{inspect res}"
  end
  test "query works" do
    map = %{key: "value"}
    attributes = [lastPostBy: "bob@bob.com",thing: 3]
    item = %Zitem{key: {:bob,:email},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
     map = %{key: "value2"}
    attributes = [lastPostBy: "joe@bob.com",thing: 2]
    item = %Zitem{key: {:joe,:email},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
     map = %{key: "value5"}
    attributes = [lastPostBy: "joe@bob.com",thing: 2]
    item = %Zitem{key: {:bob,:elk},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
     map = %{key: "value"}
    attributes = [lastPostBy: "bob@bob.com",thing: 1,other_thing: "foo"]
    item = %Zitem{key: {:bob,:phone},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
    map = %{key: "value"}
    attributes = [lastPostBy: "bob@bob.com",thing: 15]
    item = %Zitem{key: {:bob,"2"},table: "test_table",map: map,attributes: attributes}
    Zdb.put(item)
    # select hk bob, rk begins with e
    # TODO: fix :qf so that we match {attribute_name, condition, attribute_value}
    qf = [{"thing",1,:gt}]
    q = %Zq{table: "test_table",kc: [{"hk",:eq,:bob}],qf: qf}
    res = Zdb.q(q)
    assert is_list(res.items)
    assert Enum.count(res.items) == 3
    # range key between 1 and 3
    kc = [{:hk,:eq,:bob},{:rk, :between, "1","3"}]
    q = %Zq{table: "test_table",kc: kc}
  
    #TODO: figure out why this doesn't work
    res = Zdb.q(q)
    [i] = res.items
    assert i.attributes.thing == 15



    #  find other key between 1 and 3
    qf = [{"thing",2,:eq}]
    q = %Zq{table: "test_table",kc: [{"hk",:eq,:bob}],qf: qf}
    res = Zdb.q(q)
    assert Map.has_key?(res,:items)
    items = res.items
    assert Enum.count(items) == 1
    [item] = items
    assert match?(%Zitem{},item)
    assert item.attributes.thing == 2
  end
  test "streams work" do
    assert false, "not done yet, get those streams going"
  end
  test "string key works" do
    res = Zdb.item_key_to_strings({"account.AEH", "abcdefg"})
    assert res == {"account.AEH", "abcdefg"}
  end
end

Zdb
===

** Elixir access for dynamodb **


# Usage

```elixir
## create table
Zdb.create("test_table")

## create item struct

item = %Zitem{key: {:bar,:foo},table: "test_table"}

## put the item
Zdb.put(item)

## get the item
zr = Zdb.get(item)

## Enumerate items
items = zr.items
Enum.each(items,fn(i) -> IO.inspect i end)

## update the item

# setup
map = %{key: "value"}
attributes = [lastPostBy: "bob@bob.com"]
item = %Zitem{key: {:bob,:email},table: "test_table",map: map,attributes: attributes}
Zdb.put(item)

# update

updates = %Zu{attributes: [lastPostBy: "bob@bobo.com"],action: :put,
                 opts: [expected: [lastPostBy: "bob@bob.com"],
                   return_values: :all_new ]
              }
res = Zdb.update(item,updates)

## query multiple items

q = %Zq{table: "test_table",kc: [{"hk",:eq,:bob},{"rk",:begins_with,"e"}]}
res = Zdb.q(q)
```

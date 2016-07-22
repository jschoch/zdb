# this is quite dead and out of date

Zdb
===

** Elixir access for dynamodb **

[docs](http://stink.net/zdb)

# Usage


## If you want to use Dynamodb local for dev

Add the following to your <project dir>/config/#{Mix.enf}.exs

in this case :dev

    config :zdb,
      ddb_port: 8000,
      ddb_host: 'localhost',
      ddb_scheme: 'http://',
      ddb_key: 'ddb_local_' ++ (Mix.env|>Atom.to_string|> String.to_char_list),
      ddb_skey: 'ddb_local_' ++ (Mix.env|>Atom.to_string|> String.to_char_list)

then install dynamodb and fire it up....

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

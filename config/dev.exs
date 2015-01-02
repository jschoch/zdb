use Mix.Config

config :zdb,
  ddb_port: 8000,
  ddb_host: 'localhost',
  ddb_scheme: 'http://',
  ddb_key: 'ddb_local_' ++ (Mix.env|>Atom.to_string|> String.to_char_list),
  ddb_skey: 'ddb_local_' ++ (Mix.env|>Atom.to_string|> String.to_char_list)


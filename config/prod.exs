use Mix.Config

config :zdb,
  ddb_port: 80,
  ddb_host: 'dynamodb.us-east-1.amazonaws.com',
  ddb_scheme: 'https://',
  ddb_key: (System.get_env("AWS_ACCESS_KEY_ID") |> String.to_char_list),
  ddb_skey: (System.get_env("AWS_SECRET_ACCESS_KEY") |> String.to_char_list)

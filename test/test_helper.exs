ExUnit.configure(exclude: [pending: true])
ExUnit.start()
case Mix.env do
  :prod -> raise "please don't run in prod"
  :dev -> IO.puts "WARNING: running in :dev"
  :mem -> IO.puts "WARNING: in memory only!"
  :test -> IO.puts "Running in :test env"
  shit -> raise "HOLY SHIT, please get your Mix.env right #{inspect shit}"
end

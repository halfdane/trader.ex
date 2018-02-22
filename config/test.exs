use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :trader, TraderWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :trader, Trader.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "trader_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :trader, Trader.CandleTicker, max_symbol_count: 1

config :trader, Trader.SupportedSymbols, symbols: ["ETHBTC", "LTCBTC"]

config :trader, Trader.Auth.Guardian,
  issuer: "Trader",
  secret_key: "some secret"

config :bcrypt_elixir, log_rounds: 4

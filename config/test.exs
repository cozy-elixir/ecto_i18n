import Config

config :ecto_i18n, ecto_repos: [EctoI18n.Repo]

config :ecto_i18n, EctoI18n.Repo,
  username: "postgres",
  password: "postgres",
  database: "ecto_i18n_test",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

import Config

config :ecto_i18n, ecto_repos: [EctoI18n.Repo]

# Move test only migrations to test/ directory, in order to not confuse
# the developers reading code ;)
config :ecto_i18n, EctoI18n.Repo, priv: "test/priv/repo"

config :ecto_i18n, EctoI18n.Repo,
  username: "postgres",
  password: "postgres",
  database: "ecto_i18n_test",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

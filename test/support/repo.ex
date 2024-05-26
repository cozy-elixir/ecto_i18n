defmodule EctoI18n.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ecto_i18n,
    adapter: Ecto.Adapters.Postgres
end

defmodule EctoI18n.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      alias EctoI18n.Repo

      import Ecto
      import Ecto.Query
      import EctoI18n.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoI18n.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EctoI18n.Repo, {:shared, self()})
    end

    :ok
  end
end

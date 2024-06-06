defmodule EctoI18n.Repo.Migrations.CreateTestTables do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :sku, :string
      add :name_i18n, :map
      add :price_i18n, :map
    end
  end
end

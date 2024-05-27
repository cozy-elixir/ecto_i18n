defmodule EctoI18n.Repo.Migrations.CreateTestTables do
  use Ecto.Migration

  def change do
    create table :products  do
      add :sku, :string
      add :name, :string
      add :locales, :map
    end
  end
end

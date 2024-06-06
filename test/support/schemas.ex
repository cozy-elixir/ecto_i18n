defmodule EctoI18n.ProductWithoutI18nSupport do
  @moduledoc false

  use Ecto.Schema

  schema "products" do
    field :sku, :string
    field :name, :string
    # I know, I should use a real currency type.
    field :price, :integer
  end
end

defmodule EctoI18n.Product do
  @moduledoc false

  use Ecto.Schema
  use EctoI18n.Schema, locales: ["en", "zh-Hans"]

  schema "products" do
    field :sku, :string
    field_i18n :name, :string
    # I know, I should use a real currency type.
    field_i18n :price, :integer
  end
end

defmodule EctoI18n.ProductWithoutI18nSupport do
  @moduledoc false

  use Ecto.Schema

  schema "products" do
    field :sku, :string
    field :name, :string
  end
end

defmodule EctoI18n.ProductWithEctoI18nUsedOnly do
  @moduledoc false

  use Ecto.Schema
  use EctoI18n.Schema, default_locale: "en", locales: ["zh-Hans", "zh-Hant"]

  schema "products" do
    field :sku, :string
    field :name, :string
  end
end

defmodule EctoI18n.Product do
  @moduledoc false

  use Ecto.Schema
  use EctoI18n.Schema, default_locale: "en", locales: ["zh-Hans", "zh-Hant"]

  schema "products" do
    field :sku, :string
    field :name, :string

    locales :locales do
      field :name, :string
    end
  end
end

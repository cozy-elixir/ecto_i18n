defmodule EctoI18nTest do
  use ExUnit.Case
  use EctoI18n.RepoCase
  alias EctoI18n.Repo

  defmodule Product do
    use Ecto.Schema
    use EctoI18n.Schema, default_locale: :en, locales: [:"zh-Hans", :"zh-Hant"]

    schema "products" do
      field :sku, :string
      field :name, :string

      locales :locales do
        field :name, :string
      end
    end
  end

  def cast_locale(locale, attrs) do
    locale
    |> Ecto.Changeset.cast(attrs, [:name])
    |> Ecto.Changeset.validate_required([:name])
  end

  setup do
    params = %{
      sku: "12345-XYZ-789",
      name: "Isabella body wash",
      locales: %{
        "zh-Hans": %{
          name: "伊莎贝拉沐浴露"
        },
        "zh-Hant": %{
          name: "伊莎貝拉沐浴露"
        }
      }
    }

    product =
      %Product{}
      |> Ecto.Changeset.cast(params, [:sku, :name])
      |> Ecto.Changeset.validate_required([:sku, :name])
      |> EctoI18n.Changeset.cast_locales(:locales, with: &cast_locale/2)
      |> Repo.insert!()

    %{product: product}
  end

  test "localize!/2", %{product: product} do
    assert %Product{
             sku: "12345-XYZ-789",
             name: "伊莎贝拉沐浴露"
           } = EctoI18n.localize!(product, :"zh-Hans")
  end
end

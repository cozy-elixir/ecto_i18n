defmodule EctoI18n.ChangesetTest do
  use ExUnit.Case
  use EctoI18n.RepoCase
  alias EctoI18n.Repo

  @params %{
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

  defmodule Product do
    use Ecto.Schema

    schema "products" do
      field :sku, :string
      field :name, :string
    end
  end

  defmodule LocalizedProduct do
    use Ecto.Schema
    use EctoI18n.Schema, default_locale: :en, locales: [:"zh-Hans", :"zh-Hant"]

    schema "products" do
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

  describe "cast_locales/3" do
    test "raises error with the schema isn't localizable" do
      assert_raise RuntimeError,
                   "EctoI18n.ChangesetTest.Product must use `EctoI18n.Schema` in order to be localizable",
                   fn ->
                     %Product{}
                     |> Ecto.Changeset.cast(@params, [:name])
                     |> EctoI18n.Changeset.cast_locales(:locales, with: &cast_locale/2)
                   end
    end

    test "raises error with the name field isn't right" do
      assert_raise RuntimeError,
                   "EctoI18n.ChangesetTest.LocalizedProduct must call `locales :unknown, do: block` in order to be localizable",
                   fn ->
                     %LocalizedProduct{}
                     |> Ecto.Changeset.cast(@params, [:name])
                     |> EctoI18n.Changeset.cast_locales(:unknown, with: &cast_locale/2)
                   end
    end

    test "works as expected" do
      assert {:ok,
              %LocalizedProduct{
                name: "Isabella body wash",
                locales: %LocalizedProduct.Locales{
                  "zh-Hans": %LocalizedProduct.Locales.Fields{
                    name: "伊莎贝拉沐浴露"
                  },
                  "zh-Hant": %LocalizedProduct.Locales.Fields{
                    name: "伊莎貝拉沐浴露"
                  }
                }
              }} =
               %LocalizedProduct{}
               |> Ecto.Changeset.cast(@params, [:name])
               |> EctoI18n.Changeset.cast_locales(:locales, with: &cast_locale/2)
               |> Repo.insert()
    end
  end
end

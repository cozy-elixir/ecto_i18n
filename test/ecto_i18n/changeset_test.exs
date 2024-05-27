defmodule EctoI18n.ChangesetTest do
  use ExUnit.Case
  import EctoI18n.Factory
  alias EctoI18n.Product
  alias EctoI18n.ProductWithoutI18nSupport

  describe "cast_locales/3" do
    test "raises error with the schema isn't localizable" do
      assert_raise RuntimeError,
                   "EctoI18n.ProductWithoutI18nSupport must use `EctoI18n.Schema` in order to be localizable",
                   fn ->
                     %ProductWithoutI18nSupport{}
                     |> Ecto.Changeset.cast(params(:product), [:name])
                     |> EctoI18n.Changeset.cast_locales(:locales, with: &cast_locale/2)
                   end
    end

    test "raises error with the name field isn't right" do
      assert_raise RuntimeError,
                   "EctoI18n.Product must call `locales :unknown, do: block` in order to be localizable",
                   fn ->
                     %Product{}
                     |> Ecto.Changeset.cast(params(:product), [:name])
                     |> EctoI18n.Changeset.cast_locales(:unknown, with: &cast_locale/2)
                   end
    end

    test "works as expected" do
      assert %Ecto.Changeset{valid?: true} =
               %Product{}
               |> Ecto.Changeset.cast(params(:product), [:name])
               |> EctoI18n.Changeset.cast_locales(:locales, with: &cast_locale/2)
    end
  end

  defp cast_locale(locale, attrs) do
    locale
    |> Ecto.Changeset.cast(attrs, [:name])
    |> Ecto.Changeset.validate_required([:name])
  end
end

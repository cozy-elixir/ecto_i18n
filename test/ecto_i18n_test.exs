defmodule EctoI18nTest do
  use ExUnit.Case
  use EctoI18n.DataCase
  import EctoI18n.Factory

  describe "locales/1" do
    test "returns supported locales of a struct" do
      product = insert!(:product)
      assert EctoI18n.locales(product) == [:en, :"zh-Hans"]
    end

    test "returns supported locales of a module" do
      alias EctoI18n.Product
      assert EctoI18n.locales(Product) == [:en, :"zh-Hans"]
    end

    test "raises an error" do
      alias EctoI18n.ProductWithoutI18nSupport

      assert_raise RuntimeError,
                   "`EctoI18n.ProductWithoutI18nSupport` module doesn't have i18n support",
                   fn ->
                     EctoI18n.locales(EctoI18n.ProductWithoutI18nSupport)
                   end
    end
  end

  describe "localize!/2" do
    test "localizes the localizable fields" do
      product = insert!(:product)

      assert product.name == nil
      assert EctoI18n.localize!(product, "en").name == "Isabella body wash"
      assert EctoI18n.localize!(product, "zh-Hans").name == "伊莎贝拉沐浴露"

      assert product.price == nil
      assert EctoI18n.localize!(product, "en").price == 10
      assert EctoI18n.localize!(product, "zh-Hans").price == 8
    end
  end
end

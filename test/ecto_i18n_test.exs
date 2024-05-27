defmodule EctoI18nTest do
  use ExUnit.Case
  use EctoI18n.DataCase
  import EctoI18n.Factory
  alias EctoI18n.Product

  describe "localize!/2" do
    test "localizes the localizable fields" do
      product = insert!(:product)

      assert %Product{
               sku: "12345-XYZ-789",
               name: "伊莎贝拉沐浴露",
               locales: %Product.Locales{
                 "zh-Hans": %Product.Locales.Fields{name: "伊莎贝拉沐浴露"},
                 "zh-Hant": %Product.Locales.Fields{name: "伊莎貝拉沐浴露"}
               }
             } = EctoI18n.localize!(product, :"zh-Hans")
    end
  end
end

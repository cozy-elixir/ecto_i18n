defmodule EctoI18nTest do
  use ExUnit.Case
  use EctoI18n.DataCase
  import EctoI18n.Factory

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

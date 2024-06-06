defmodule EctoI18n.SchemaTest do
  use ExUnit.Case

  test "expected fields are created" do
    alias EctoI18n.Product

    assert Product.__schema__(:fields) == [:id, :sku, :name_i18n, :price_i18n]
    assert Product.__schema__(:virtual_fields) == [:name, :price]
  end

  test "expected reflection functions are created" do
    alias EctoI18n.Product

    assert Product.__ecto_i18n__(:locales) == [:en, :"zh-Hans"]
    assert Product.__ecto_i18n__(:fields) == [:name, :price]
    assert Product.__ecto_i18n__(:i18n_fields) == [:name_i18n, :price_i18n]
    assert Product.__ecto_i18n__(:mappings) == [{:name, :name_i18n}, {:price, :price_i18n}]
  end
end

defmodule EctoI18n.SchemaTest do
  use ExUnit.Case

  describe "__ecto_i18n_schema__/1" do
    test "is only callable with :default_locale and :locales when locales/2 macro is not called" do
      alias EctoI18n.ProductWithEctoI18nUsedOnly

      assert ProductWithEctoI18nUsedOnly.__ecto_i18n_schema__(:default_locale) == :en

      assert ProductWithEctoI18nUsedOnly.__ecto_i18n_schema__(:locales) == [
               :"zh-Hans",
               :"zh-Hant"
             ]

      assert_raise FunctionClauseError,
                   "no function clause matching in EctoI18n.ProductWithEctoI18nUsedOnly.__ecto_i18n_schema__/1",
                   fn ->
                     ProductWithEctoI18nUsedOnly.__ecto_i18n_schema__(:name)
                   end

      assert_raise FunctionClauseError,
                   "no function clause matching in EctoI18n.ProductWithEctoI18nUsedOnly.__ecto_i18n_schema__/1",
                   fn ->
                     ProductWithEctoI18nUsedOnly.__ecto_i18n_schema__(:fields)
                   end
    end

    test "is callable with all possible arguments when locales/2 macro is called" do
      alias EctoI18n.Product

      assert Product.__ecto_i18n_schema__(:default_locale) == :en
      assert Product.__ecto_i18n_schema__(:locales) == [:"zh-Hans", :"zh-Hant"]
      assert Product.__ecto_i18n_schema__(:locales_name) == :locales
      assert Product.__ecto_i18n_schema__(:locales_fields) == [:name]
    end
  end

  test "locales/2 macro must be called with fields which are already defined in the schema" do
    assert_raise ArgumentError,
                 "EctoI18n.SchemaTest.BadProduct declares localized fields which are not defined in the schema: [:price]",
                 fn ->
                   defmodule BadProduct do
                     use Ecto.Schema
                     use EctoI18n.Schema, default_locale: :en, locales: [:"zh-Hans", :"zh-Hant"]

                     schema "products" do
                       field :sku, :string
                       field :name, :string

                       locales :locales do
                         field :name, :string
                         field :price, :integer
                       end
                     end
                   end
                 end
  end
end

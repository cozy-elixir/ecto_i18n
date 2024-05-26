defmodule EctoI18n.SchemaTest do
  use ExUnit.Case

  defmodule Product do
    use Ecto.Schema
    use EctoI18n.Schema, default_locale: :en, locales: [:"zh-Hans", :"zh-Hant"]

    schema "products" do
      field :sku, :string
      field :name, :string
    end
  end

  defmodule LocalizedProduct do
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

  describe "__ecto_i18n_schema__/1" do
    test "is only callable with :default_locale and :locales when locales/2 macro is not called" do
      assert Product.__ecto_i18n_schema__(:default_locale) == :en
      assert Product.__ecto_i18n_schema__(:locales) == [:"zh-Hans", :"zh-Hant"]

      assert_raise FunctionClauseError,
                   "no function clause matching in EctoI18n.SchemaTest.Product.__ecto_i18n_schema__/1",
                   fn ->
                     Product.__ecto_i18n_schema__(:name)
                   end

      assert_raise FunctionClauseError,
                   "no function clause matching in EctoI18n.SchemaTest.Product.__ecto_i18n_schema__/1",
                   fn ->
                     Product.__ecto_i18n_schema__(:fields)
                   end
    end

    test "is callable with all possible arguments when locales/2 macro is called" do
      assert LocalizedProduct.__ecto_i18n_schema__(:default_locale) == :en
      assert LocalizedProduct.__ecto_i18n_schema__(:locales) == [:"zh-Hans", :"zh-Hant"]
      assert LocalizedProduct.__ecto_i18n_schema__(:locales_name) == :locales
      assert LocalizedProduct.__ecto_i18n_schema__(:locales_fields) == [:name]
    end
  end

  test "locales/2 macro must be called with fields which are already defined in the schema" do
    assert_raise ArgumentError,
                 "EctoI18n.SchemaTest.BadLocalizedProduct declares localized fields which are not defined in the schema: [:price]",
                 fn ->
                   defmodule BadLocalizedProduct do
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

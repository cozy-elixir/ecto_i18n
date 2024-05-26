defmodule EctoI18n.Changeset do
  @moduledoc """
  Provides i18n extensions for `Ecto.Changeset`.
  """

  import Ecto.Changeset, only: [cast: 3, cast_embed: 3]

  @doc """
  Casts field which is added by `locales/2` macro.

  > The `:with` option is always required.

  > It is built on the top of `Ecto.Changeset.cast_embed/3`.

  ## Example

      defmodule MyApp.Shop.Product do
        use Ecto.Schema
        import Ecto.Changeset
        use EctoI18n.Schema, default_locale: :en, locales: [:"zh-Hans", :"zh-Hant"]
        import EctoI18n.Changeset

        schema "products" do
          field :sku, :string
          field :name, :string

          locales :locales do
            field :name, :string
          end

          timestamps()
        end

        def changeset(product, attrs) do
          product
          |> cast(attrs, [:sku, :name])
          |> cast_locales(:locales, with: &cast_locale/2)
        end

        def cast_locale(locale, attrs) do
          locale
          |> cast(attrs, [:name])
          |> validate_required([:name])
        end
      end

  In above code, `changeset/2` equals to:

      def changeset(product, attrs) do
        product
        |> cast(attrs, [:sku, :name])
        |> cast_embed(:locales, with: &cast_locales/2)
      end

      defp cast_locales(locales, attrs) do
        locales
        |> cast(attrs, [])
        |> cast_embed(:"zh-Hans", with: &cast_locale/2)
        |> cast_embed(:"zh-Hant", with: &cast_locale/2)
      end

  """
  def cast_locales(changeset, name, opts) do
    inner_with_fun = Keyword.fetch!(opts, :with)

    struct = changeset.data
    module = struct.__struct__

    EctoI18n.schema_used!(module)
    EctoI18n.schema_locales_called!(module)
    EctoI18n.schema_locales_name!(module, name)

    cast_embed(changeset, name, with: build_with_fun(module, inner_with_fun))
  end

  defp build_with_fun(module, inner_with_fun) do
    locales = module.__ecto_i18n_schema__(:locales)

    fn struct, attrs ->
      struct
      |> cast(attrs, [])
      |> then(
        &Enum.reduce(locales, &1, fn locale, changeset ->
          cast_embed(changeset, locale, with: inner_with_fun)
        end)
      )
    end
  end
end

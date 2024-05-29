defmodule EctoI18n.Changeset do
  @moduledoc """
  Provides i18n extensions for `Ecto.Changeset`.
  """

  import Ecto.Changeset, only: [cast: 3, cast_embed: 3]

  @doc """
  Casts field which is added by `locales/2` macro.

  > The `:with` option is always required.
  >
  > `EcotI18n.Schema` doesn't generate any default `changeset/2` function
  > for the generated schemas. This is intentional. Because no matter what
  > I do, some needs will be hard to meet, so it's better to leave the
  > specific implementation to the developer.

  > It is built on the top of `Ecto.Changeset.cast_embed/3`.

  ## Example

      defmodule MyApp.Shop.Product do
        use Ecto.Schema
        import Ecto.Changeset
        use EctoI18n.Schema, locales: ["en", "zh-Hans", "zh-Hant"], default_locale: "en"
        import EctoI18n.Changeset

        schema "products" do
          field :sku, :string
          field :name, :string

          locales :locales do
            field :name, :string
          end
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
        |> cast_embed(:locales, required: true, with: &cast_locales/2)
      end

      defp cast_locales(locales, attrs) do
        locales
        |> cast(attrs, [])
        |> cast_embed(:"zh-Hans", required: true, with: &cast_locale/2)
        |> cast_embed(:"zh-Hant", required: true, with: &cast_locale/2)
      end

  """
  def cast_locales(changeset, name, opts) do
    struct = changeset.data
    module = struct.__struct__

    EctoI18n.schema_used!(module)
    EctoI18n.schema_locales_called!(module)
    EctoI18n.schema_locales_name!(module, name)

    cast_embed(changeset, name,
      required: true,
      with: build_with_fun(module, opts)
    )
  end

  defp build_with_fun(module, opts) do
    required_locales = module.__ecto_i18n_schema__(:required_locales)
    opts = Keyword.put_new(opts, :required, true)

    fn struct, attrs ->
      struct
      |> cast(attrs, [])
      |> then(
        &Enum.reduce(required_locales, &1, fn locale, changeset ->
          cast_embed(changeset, locale, opts)
        end)
      )
    end
  end
end

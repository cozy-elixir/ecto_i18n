defmodule EctoI18n.Changeset do
  @moduledoc """
  Provides i18n extensions for `Ecto.Changeset`.
  """

  import Ecto.Changeset, only: [cast_embed: 3]

  @doc """
  Casts field which is added by `field_i18n/_` macro.

  > It is built on the top of `Ecto.Changeset.cast_embed/3`.

  ## Example

      defmodule MyApp.Shop.Product do
        use Ecto.Schema
        import Ecto.Changeset
        use EctoI18n.Schema, locales: ["en", "zh-Hans"]
        import EctoI18n.Changeset

        schema "products" do
          field :sku, :string
          field_i18n :name, :string
        end

        def changeset(product, attrs) do
          product
          |> cast(attrs, [:sku])
          |> cast_i18n(:name, required: true)
        end
      end

  In above code, `changeset/2` equals to:

      def changeset(product, attrs) do
        product
        |> cast(attrs, [:sku, :name])
        |> cast_embed(:name_i18n, required: true)
      end

  """
  def cast_i18n(changeset, name, opts \\ []) do
    struct = changeset.data
    module = struct.__struct__
    name_i18n = :"#{name}_i18n"

    unless EctoI18n.i18n_support?(module, name) do
      raise RuntimeError,
            "`#{inspect(name)}` field of `#{inspect(module)}` doesn't have i18n support"
    end

    cast_embed(changeset, name_i18n, opts)
  end
end

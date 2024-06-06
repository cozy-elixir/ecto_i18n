defmodule EctoI18n do
  @moduledoc """
  Provides i18n support for Ecto.

  ## Preface

  There're [lots of strategies to localize contents in database](https://dejimata.com/2017/3/3/translating-with-mobility)
  ([archived](https://web.archive.org/web/20240528023514/https://dejimata.com/2017/3/3/translating-with-mobility)).
  For now, `#{inspect(__MODULE__)}` implements only strategy 6 mentioned
  above - creating an extra column for storing all the localized data
  for that table.

  With this strategy, it can:

    * avoid using extra tables for storing localized data.
    * avoid using complex JOINs when retrieving localized data.

  > Maybe other strategies will be implemented later, but for now, I only
  > need this one.

  ## Quick start

  Let's say that we have a schema which needs to be localized:

      defmodule MyApp.Shop.Product do
        use Ecto.Schema

        schema "products" do
          field :sku, :string
          field :name, :string
        end
      end

  The first step is to add a new column to the table at database level, so
  we can store localized data in it:

      defmodule MyApp.Repo.Migrations.AddLocalesToProducts do
        use Ecto.Migration

        def change do
          alter table(:products) do
            add :name_i18n, :map
          end
        end
      end

  The second step is to update schema for using the new column:

      defmodule MyApp.Shop.Product do
        use Ecto.Schema
        use EctoI18n.Schema, locales: ["en", "zh-Hans"]

        schema "products" do
          field :sku, :string
          field_i18n :name, :string
        end
      end

  > If you're curious about the underlying implementation here, you can read
  > `EctoI18n.Schema` to learn more.

  Next, you can use the extensions provided by `#{inspect(__MODULE__)}` to
  work with the localized schema, such as:

    * `EctoI18n.i18n_support?/1` / `EctoI18n.i18n_support?/2`
    * `EctoI18n.locales/1`
    * `EctoI18n.localize!/2`
    * `EctoI18n.Changeset.cast_i18n/2` / `EctoI18n.Changeset.cast_i18n/3`
    * `EctoI18n.Query` (Still in planning)
    * ...

  """

  @type locale :: atom() | binary()

  @doc """
  Checks whether a module or a struct has i18n support.

  ## Examples

      iex> EctoI18n.localizable?(Product)
      iex> EctoI18n.localizable?(%Product{})

  """
  @spec i18n_support?(module() | struct()) :: boolean()
  def i18n_support?(module_or_struct)

  def i18n_support?(module) when is_atom(module) do
    {:__ecto_i18n__, 1} in module.__info__(:functions)
  end

  def i18n_support?(struct) when is_struct(struct) do
    module = struct.__struct__
    i18n_support?(module)
  end

  @spec i18n_support?(module() | struct(), atom()) :: boolean()
  def i18n_support?(module_or_struct, field)

  def i18n_support?(module, field) when is_atom(module) do
    i18n_support?(module) && field in module.__ecto_i18n__(:fields)
  end

  def i18n_support?(struct, field) when is_struct(struct) do
    module = struct.__struct__
    i18n_support?(module, field)
  end

  @doc """
  Returns supported locales of a struct or the underlying module.
  """
  @spec locales(module() | struct()) :: [locale()]
  def locales(module_or_struct)

  def locales(module) when is_atom(module) do
    unless i18n_support?(module) do
      raise RuntimeError,
            "`#{inspect(module)}` module doesn't have i18n support"
    end

    module.__ecto_i18n__(:locales)
  end

  def locales(struct) when is_struct(struct) do
    module = struct.__struct__
    locales(module)
  end

  @doc """
  Localizes a struct with given locale recursively.

  All localizable values in the struct will be localized into the give locale.

  ## Examples

      iex> EctoI18n.localize!(product, "zh-Hans")

  """
  @spec localize!(struct(), locale()) :: struct()
  def localize!(struct, locale) when is_struct(struct) and is_atom(locale),
    do: do_localize!(struct, locale)

  def localize!(struct, locale) when is_struct(struct) and is_binary(locale),
    do: do_localize!(struct, String.to_atom(locale))

  defp do_localize!(%Ecto.Association.NotLoaded{} = term, _locale), do: term

  defp do_localize!(%{__meta__: _} = struct, locale) when is_struct(struct) do
    module = struct.__struct__

    struct =
      if EctoI18n.i18n_support?(module) do
        mappings = module.__ecto_i18n__(:mappings)

        Enum.reduce(mappings, struct, fn {field, i18n_field}, acc ->
          value = struct |> Map.fetch!(i18n_field) |> Map.fetch!(locale)
          Kernel.struct(acc, [{field, value}])
        end)
      else
        struct
      end

    associations = module.__schema__(:associations)
    embeds = module.__schema__(:embeds)
    assocs = associations ++ embeds

    Enum.reduce(assocs, struct, fn assoc, struct ->
      Map.update!(struct, assoc, &do_localize!(&1, locale))
    end)
  end

  defp do_localize!(struct, locale) when is_struct(struct) do
    keys = Map.keys(struct) -- [:__struct__]

    Enum.reduce(keys, struct, fn key, struct ->
      Map.update!(struct, key, &do_localize!(&1, locale))
    end)
  end

  defp do_localize!(map, locale) when is_map(map) do
    Enum.into(map, %{}, fn {k, v} -> {k, do_localize!(v, locale)} end)
  end

  defp do_localize!(list, locale) when is_list(list) do
    Enum.map(list, fn term -> do_localize!(term, locale) end)
  end

  defp do_localize!(term, _locale), do: term
end

defmodule EctoI18n do
  @moduledoc """
  Provides i18n support for Ecto.

  ## Preface

  There're [lots of strategies to localize contents in database](https://dejimata.com/2017/3/3/translating-with-mobility).

  For now, `#{inspect(__MODULE__)}` implements only strategy 6 mentioned
  above - creating an extra column for storing all the localized contents
  for that table.

  In this way, it can:

    * avoid using extra tables for storing localized contents.
    * avoid using complex JOINs when retrieving localized contents.

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
  we can store localized contents in it:

      defmodule MyApp.Repo.Migrations.AddLocalesToProducts do
        use Ecto.Migration

        def change do
          alter table(:products) do
            add :locales, :map
          end
        end
      end

  The second step is to update schema for using the new column:

      defmodule MyApp.Shop.Product do
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

  > If you're curious about the underlying implementation here, you can read
  > `EctoI18n.Schema.locales/2` to learn more.

  Next, you can use the extensions provided by `#{inspect(__MODULE__)}` to
  work with the localized schema, such as:

    * `EctoI18n.localize!/2`
    * `EctoI18n.Changeset.cast_locales/3`
    * `EctoI18n.Query` (Still in planning)
    * ...

  """

  @doc """
  Checks whether a module or a struct is localizable.

  ## Examples

      iex> EctoI18n.localizable?(Product)
      iex> EctoI18n.localizable?(%Product{})

  """
  @spec localizable?(module() | struct()) :: boolean()
  def localizable?(module_or_struct)

  def localizable?(module) when is_atom(module) do
    schema_used?(module) &&
      schema_locales_called?(module)
  end

  def localizable?(struct) when is_struct(struct) do
    module = struct.__struct__
    localizable?(module)
  end

  @doc """
  Ensures that a module or a struct is localizable. Or, an error is raised.
  """
  @spec localizable!(module() | struct()) :: module() | struct()
  def localizable!(module_or_struct)

  def localizable!(module) when is_atom(module) do
    schema_used!(module)
    schema_locales_called!(module)

    module
  end

  def localizable!(struct) when is_struct(struct) do
    module = struct.__struct__
    localizable!(module)

    struct
  end

  @doc """
  Checks whether a field in a module or a struct is localizable.

  ## Examples

      iex> Ecto.localizable?(Product, :name)
      iex> Ecto.localizable?(%Product{}, :name)

  """
  @spec localizable?(module() | struct(), atom()) :: boolean()
  def localizable?(module_or_struct, field)

  def localizable?(module, field) when is_atom(module) and is_atom(field) do
    schema_used?(module) &&
      schema_locales_called?(module) &&
      schema_locales_field?(module, field)
  end

  def localizable?(struct, field) when is_struct(struct) and is_atom(field) do
    module = struct.__struct__
    localizable?(module, field)
  end

  @doc """
  Localizes a struct with given locale recursively.

  All localizable values in the struct will be localized into the give locale.

  ## Examples

      iex> EctoI18n.localize!(product, :"zh-Hans")

  """
  @spec localize!(struct(), atom()) :: struct()
  def localize!(struct, locale) when is_struct(struct) and is_atom(locale),
    do: do_localize!(struct, locale)

  defp do_localize!(%Ecto.Association.NotLoaded{} = term, _locale), do: term

  defp do_localize!(%{__meta__: _} = struct, locale) when is_struct(struct) do
    module = struct.__struct__

    struct =
      if EctoI18n.localizable?(module) &&
           locale !== module.__ecto_i18n_schema__(:default_locale) do
        schema_locale!(module, locale)

        locales_name = module.__ecto_i18n_schema__(:locales_name)
        fields = module.__ecto_i18n_schema__(:locales_fields)

        base_fields = Map.from_keys(fields, nil)

        localized_fields =
          struct
          |> Map.fetch!(locales_name)
          |> Map.fetch!(locale)
          |> Map.take(fields)
          |> then(&Map.merge(base_fields, &1))

        Map.merge(struct, localized_fields)
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

  # Helper functions

  @doc false
  def schema_used?(module) do
    try do
      module.__ecto_i18n_schema__(:used?)
    rescue
      [ArgumentError, UndefinedFunctionError] ->
        false
    end
  end

  @doc false
  def schema_used!(module) do
    unless schema_used?(module) do
      raise "#{inspect(module)} must use `EctoI18n.Schema` in order to be localizable"
    end
  end

  @doc false
  def schema_locales_called?(module) do
    try do
      module.__ecto_i18n_schema__(:locales_called?)
    rescue
      [ArgumentError, UndefinedFunctionError] ->
        false
    end
  end

  @doc false
  def schema_locales_called!(module) do
    unless schema_locales_called?(module) do
      raise "#{inspect(module)} must call `locales/2` in order to be localizable"
    end
  end

  @doc false
  def schema_locales_name?(module, name) do
    try do
      name == module.__ecto_i18n_schema__(:locales_name)
    rescue
      [ArgumentError, UndefinedFunctionError] ->
        false
    end
  end

  @doc false
  def schema_locales_name!(module, name) do
    unless schema_locales_name?(module, name) do
      raise "#{inspect(module)} must call `locales #{inspect(name)}, do: block` in order to be localizable"
    end
  end

  @doc false
  def schema_locale?(module, locale) do
    try do
      locale in module.__ecto_i18n_schema__(:locales)
    rescue
      [ArgumentError, UndefinedFunctionError] ->
        false
    end
  end

  @doc false
  def schema_locale!(module, locale) do
    unless schema_locale?(module, locale) do
      raise "#{inspect(module)} doesn't support #{inspect(locale)} locale"
    end
  end

  @doc false
  def schema_locales_field?(module, field) do
    try do
      field in module.__ecto_i18n_schema__(:locales_fields)
    rescue
      [ArgumentError, UndefinedFunctionError] ->
        false
    end
  end
end

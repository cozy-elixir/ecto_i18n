defmodule EctoI18n.Schema do
  @moduledoc """
  Provides i18n extensions for `Ecto.Schema`.
  """

  defmacro __using__(opts) do
    quote do
      @ecto_i18n_schema_default_locale unquote(build_schema_default_locale(opts))
      @ecto_i18n_schema_locales unquote(build_schema_locales(opts))

      import unquote(__MODULE__), only: [locales: 2]

      def __ecto_i18n_schema__(:used?), do: true

      def __ecto_i18n_schema__(:default_locale),
        do: @ecto_i18n_schema_default_locale

      def __ecto_i18n_schema__(:locales),
        do: @ecto_i18n_schema_locales -- [@ecto_i18n_schema_default_locale]
    end
  end

  @doc """
  Creates a field for storing localized contents.

  ## Example

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

  In above code, calling:

      locales :locales do
        field :name, :string
      end

  equals to:

      embeds_one :locales, Locales do
        embeds_one :"zh-Hans", Fields
        embeds_one :"zh-Hant", Fields
      end

  The `Locales` and `Fields` modules will be created automatically.

  """
  defmacro locales(name, do: block) when is_atom(name) do
    caller = __CALLER__

    locales_module =
      name
      |> to_string()
      |> Macro.camelize()
      |> then(&Module.concat([__CALLER__.module, &1]))

    locales_block = Macro.escape(block)

    quote do
      if line = Module.get_attribute(__MODULE__, :ecto_i18n_schema_locales_called) do
        raise "locales/2 can only be called once for #{inspect(__MODULE__)}"
      end

      @ecto_i18n_schema_locales_called unquote(caller.line)

      @ecto_i18n_schema_locales_name unquote(name)
      @ecto_i18n_schema_locales_module unquote(locales_module)
      @ecto_i18n_schema_locales_block unquote(locales_block)

      @before_compile {unquote(__MODULE__), :__locales_prepare__}
      @after_compile {unquote(__MODULE__), :__locales_validate_fields__}

      embeds_one(unquote(name), unquote(locales_module), on_replace: :update)
    end
  end

  defmacro __locales_prepare__(env) do
    locales = Module.get_attribute(env.module, :ecto_i18n_schema_locales)

    locales_name = Module.get_attribute(env.module, :ecto_i18n_schema_locales_name)
    locales_module = Module.get_attribute(env.module, :ecto_i18n_schema_locales_module)
    locales_block = Module.get_attribute(env.module, :ecto_i18n_schema_locales_block)
    locales_fields_module = Module.concat(locales_module, Fields)

    quote do
      defmodule unquote(locales_module) do
        @moduledoc false

        use Ecto.Schema

        @primary_key false
        embedded_schema do
          for locale <- List.wrap(unquote(locales)) do
            embeds_one(locale, unquote(locales_fields_module), on_replace: :update)
          end
        end
      end

      defmodule unquote(locales_fields_module) do
        @moduledoc false

        use Ecto.Schema

        @primary_key false
        embedded_schema(do: unquote(locales_block))
      end

      def __ecto_i18n_schema__(:locales_called?), do: true
      def __ecto_i18n_schema__(:locales_name), do: unquote(locales_name)

      def __ecto_i18n_schema__(:locales_fields),
        do: unquote(locales_fields_module).__schema__(:fields)
    end
  end

  @doc false
  def __locales_validate_fields__(%{module: module}, _) do
    struct_fields =
      module.__schema__(:fields)
      |> MapSet.new()

    localizable_fields =
      module.__ecto_i18n_schema__(:locales_fields)
      |> MapSet.new()

    invalid_fields = MapSet.difference(localizable_fields, struct_fields)

    if MapSet.size(invalid_fields) > 0 do
      raise ArgumentError,
        message:
          "#{inspect(module)} declares localized fields which are not defined in the schema: #{inspect(MapSet.to_list(invalid_fields))}"
    end
  end

  defp build_schema_default_locale(opts) do
    opt_name = :default_locale

    case Keyword.fetch(opts, opt_name) do
      {:ok, default_locale} ->
        default_locale

      :error ->
        raise ArgumentError,
          message: "#{inspect(__MODULE__)} requires #{inspect(opt_name)} option"
    end
  end

  defp build_schema_locales(opts) do
    opt_name = :locales

    case Keyword.fetch(opts, opt_name) do
      {:ok, locales} ->
        locales

      :error ->
        raise ArgumentError,
          message: "#{inspect(__MODULE__)} requires #{inspect(opt_name)} option"
    end
  end
end

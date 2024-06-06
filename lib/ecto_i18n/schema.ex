defmodule EctoI18n.Schema do
  @moduledoc """
  Provides i18n extensions for `Ecto.Schema`.
  """

  defmacro __using__(opts) do
    quote do
      @ecto_i18n_locales unquote(build_schema_locales(opts))
      Module.register_attribute(__MODULE__, :ecto_i18n_fields, accumulate: true)

      @before_compile {unquote(__MODULE__), :__before_compile__}

      import unquote(__MODULE__), only: [field_i18n: 1, field_i18n: 2, field_i18n: 3]
    end
  end

  defmacro __before_compile__(env) do
    locales = Module.get_attribute(env.module, :ecto_i18n_locales)
    fields = Module.get_attribute(env.module, :ecto_i18n_fields) |> Enum.reverse()

    modules =
      Enum.map(fields, fn {_name, _name_i18n, type, opts, mod} ->
        quote do
          defmodule unquote(mod) do
            @moduledoc false

            use Ecto.Schema
            import Ecto.Changeset

            @primary_key false
            embedded_schema do
              for locale <- List.wrap(unquote(locales)) do
                field locale, unquote(type), unquote(opts)
              end
            end

            @doc false
            def changeset(struct, params) do
              struct
              |> cast(params, unquote(locales))
              |> validate_required(unquote(locales))
            end
          end
        end
      end)

    reflections =
      quote do
        def __ecto_i18n__(:locales), do: unquote(locales)
        def __ecto_i18n__(:fields), do: unquote(Enum.map(fields, &elem(&1, 0)))
        def __ecto_i18n__(:i18n_fields), do: unquote(Enum.map(fields, &elem(&1, 1)))
        def __ecto_i18n__(:mappings), do: unquote(Enum.map(fields, &{elem(&1, 0), elem(&1, 1)}))
      end

    [modules, reflections]
  end

  @doc """
  Creates a virtual field and an embed for storing localized data.

  ## Example

      defmodule MyApp.Shop.Product do
        use Ecto.Schema
        use EctoI18n.Schema, locales: ["en", "zh-Hans"]

        schema "products" do
          field :sku, :string
          field_i18n :name, :string
        end
      end

  In above code, calling:

      field_i18n :name, :string

  equals to:

      field :name, :string, virtual: true
      embeds_one :name_i18n, NameI18n do
        field :"en", :string
        field :"zh-Hans", :string
      end

  The `NameI18n` module will be generated automatically.

  """
  defmacro field_i18n(name, type \\ :string, opts \\ []) when is_atom(name) do
    caller = __CALLER__
    name_i18n = to_atom("#{name}_i18n")
    module_i18n = Module.concat([caller.module, "#{Macro.camelize(to_string(name))}I18n"])

    quote do
      Module.put_attribute(
        __MODULE__,
        :ecto_i18n_fields,
        {unquote(name), unquote(name_i18n), unquote(type), unquote(opts), unquote(module_i18n)}
      )

      field unquote(name), unquote(type), unquote(Keyword.put(opts, :virtual, true))
      embeds_one unquote(name_i18n), unquote(module_i18n), on_replace: :update
    end
  end

  defp build_schema_locales(opts) do
    opt_name = :locales

    case Keyword.fetch(opts, opt_name) do
      {:ok, locales} ->
        Enum.map(locales, &to_atom/1)

      :error ->
        raise ArgumentError,
          message: "#{inspect(__MODULE__)} requires #{inspect(opt_name)} option"
    end
  end

  defp to_atom(string) when is_binary(string), do: String.to_atom(string)
  defp to_atom(atom) when is_atom(atom), do: atom
end

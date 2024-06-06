defmodule EctoI18n.Type do
  use Ecto.ParameterizedType

  @impl true
  def init(opts) do
    inner_type = Keyword.fetch!(opts, :inner_type)
    locales = Keyword.fetch!(opts, :locales)
    %{inner_type: inner_type, locales: locales}
  end

  @impl true
  def type(%{inner_type: inner_type}), do: {:map, inner_type}

  @impl true
  def cast(nil, _params), do: {:ok, nil}

  def cast(%{} = map, %{inner_type: inner_type, locales: locales}) do
    cond do
      locales -- Map.keys(map) != [] ->
        :error

      true ->
        map
        |> Enum.filter(fn {k, _v} -> k in locales end)
        |> Enum.reduce_while([], fn {k, v}, acc ->
          case cast(inner_type, v) do
            {:ok, casted_value} -> {:cont, [{k, casted_value} | acc]}
            _ -> {:halt, :error}
          end
        end)
        |> case do
          :error ->
            :error

          kvs when is_list(kvs) ->
            map = Enum.into(kvs, %{}, Enum.reverse(kvs))
            {:ok, map}
        end
    end
  end

  def cast(_, _), do: :error

  @impl true
  def dump(nil, _, _), do: {:ok, nil}

  def dump(%{} = map, _, %{inner_type: inner_type}) do
    map = Enum.into(map, %{}, fn {k, v} -> {k, dump!(inner_type, v)} end)
    {:ok, map}
  end

  def dump(_, _, _), do: :error

  @impl true
  def load(nil, _, _), do: nil

  def load(map, _, %{inner_type: inner_type, locales: locales}) do
    map =
      map
      |> Enum.filter(fn {k, _v} -> k in locales end)
      |> Enum.into(%{}, fn {k, v} -> {k, load!(inner_type, v)} end)

    {:ok, map}
  end

  def load(_, _, _), do: :error

  @impl true
  def format(%{locales: locales}) do
    "#{inspect(__MODULE__)}<locales: #{inspect(locales)}>"
  end

  defp cast!(type, value) do
    case Ecto.Type.cast(type, value) do
      {:ok, casted_value} -> casted_value
      :error -> raise Ecto.CastError, type: type, value: value
    end
  end

  defp dump!(type, value) do
    case Ecto.Type.dump(type, value) do
      {:ok, dumped_value} -> dumped_value
      :error -> raise ArgumentError, "cannot dump #{inspect(type)} value: #{inspect(value)}"
    end
  end

  defp load!(type, value) do
    case Ecto.Type.load(type, value) do
      {:ok, loaded_value} -> loaded_value
      :error -> raise ArgumentError, "cannot load #{inspect(type)} value: #{inspect(value)}"
    end
  end
end

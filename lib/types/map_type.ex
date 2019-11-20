defmodule Talos.Types.MapType do
  @moduledoc false
  defstruct [:fields]

  @behaviour Talos.Types

  @default_options %{optional: false, allow_nil: false}

  def valid?(%__MODULE__{fields: nil}, value) do
    is_map(value)
  end

  def valid?(%__MODULE__{fields: fields}, value) do
    is_map(value) &&
      Enum.all?(fields, fn field ->
        case field do
          {key, type} ->
            validation_check(type, value, key)

          {key, type, options} ->
            validation_check(type, value, key, options)
        end
      end)
  end

  def errors(%__MODULE__{fields: fields} = type, value) do
    cond do
      is_nil(fields) && is_map(value) ->
        %{}

      !is_map(value) ->
        ["#{inspect(value)} does not match #{inspect(type)}"]

      !valid?(type, value) ->
        errors_for_fields(fields, value)

      true ->
        %{}
    end
  end

  defp errors_for_fields(fields, map) do
    fields
    |> Enum.map(fn field ->
      case field do
        {key, type} ->
          case validation_check(type, map, key) do
            true -> nil
            false -> {key, Talos.errors(type, map[key])}
          end

        {key, type, options} ->
          case validation_check(type, map, key, options) do
            true -> nil
            false -> {key, Talos.errors(type, map[key])}
          end
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end

  defp validation_check(type, map, key, opts \\ %{}) do
    options = Map.merge(@default_options, Map.new(opts))

    cond do
      options[:optional] && !Map.has_key?(map, key) -> true
      !options[:optional] && !Map.has_key?(map, key) -> false
      Map.has_key?(map, key) && options[:allow_nil] && is_nil(map[key]) -> true
      Map.has_key?(map, key) && !options[:allow_nil] && is_nil(map[key]) -> false
      is_nil(type) -> true
      true -> Talos.valid?(type, map[key])
    end
  end
end

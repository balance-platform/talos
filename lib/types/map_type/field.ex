defmodule Talos.Types.MapType.Field do
  @moduledoc false

  # Belongs mostly to MapType, and used for key-value pairs

  @enforce_keys [:key, :type]
  defstruct [
    :key,
    :type,
    :description,
    :default_value,
    example_value: nil,
    optional: false,
    if_any: false
  ]

  @type t :: %{
          __struct__: atom,
          key: any,
          type: any,
          description: String.t(),
          default_value: any,
          example_value: any,
          optional: boolean,
          if_any: boolean
        }

  def valid?(%__MODULE__{} = field, expected_map_value)
      when is_map(expected_map_value) do
    {_key, errors} = errors(field, expected_map_value)

    errors in [%{}, []]
  end

  def errors(%__MODULE__{if_any: true} = field, expected_map_value) do
    keys = Map.keys(expected_map_value)
    is_key_missed = !Map.has_key?(expected_map_value, field.key)
    empty_values = Enum.all?(expected_map_value, fn {_k, value} -> is_nil(value) end)

    cond do
      Enum.empty?(keys) ->
        {field.key, ["one of keys should exist"]}

      is_key_missed && !empty_values ->
        {field.key, []}

      !is_key_missed && is_nil(expected_map_value[field.key]) && !empty_values ->
        {field.key, []}

      true ->
        {field.key, Talos.errors(field.type, expected_map_value[field.key])}
    end
  end

  def errors(%__MODULE__{if_any: false, optional: is_optional} = field, expected_map_value)
      when is_map(expected_map_value) do
    is_key_missed = !Map.has_key?(expected_map_value, field.key)

    cond do
      is_key_missed && !is_optional -> {field.key, ["should exist"]}
      is_key_missed && is_optional -> {field.key, []}
      true -> {field.key, Talos.errors(field.type, expected_map_value[field.key])}
    end
  end
end

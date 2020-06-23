defmodule Talos.Field do
  @moduledoc false

  # Belongs mostly to MapType, and used for key-value pairs
  @deprecated "Module deprecated, use import Talos instead, will be removed in 1.7"
  @enforce_keys [:key, :type]
  defstruct [:key, :type, :description, :default_value, example_value: nil, optional: false]

  @type t :: %{
          __struct__: atom,
          key: any,
          type: any,
          description: String.t(),
          default_value: any,
          example_value: any,
          optional: boolean
        }

  def valid?(%__MODULE__{} = field, expected_map_value)
      when is_map(expected_map_value) do
    {_key, errors} = errors(field, expected_map_value)

    errors in [%{}, []]
  end

  def errors(%__MODULE__{optional: is_optional} = field, expected_map_value)
      when is_map(expected_map_value) do
    is_key_missed = !Map.has_key?(expected_map_value, field.key)

    cond do
      is_key_missed && !is_optional -> {field.key, ["should exist"]}
      is_key_missed && is_optional -> {field.key, []}
      true -> {field.key, Talos.errors(field.type, expected_map_value[field.key])}
    end
  end
end

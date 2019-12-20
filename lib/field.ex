defmodule Talos.Field do
  @moduledoc false
  # Belongs mostly to MapType, and used for key-value pairs

  @enforce_keys [:key, :type]
  defstruct [:key, :type, :description, :default_value, optional: false]

  @type t :: %{
          __struct__: atom,
          key: any,
          type: any,
          description: String.t(),
          default_value: any,
          optional: boolean
        }

  def valid?(%__MODULE__{optional: is_optional} = field, expected_map_value)
      when is_map(expected_map_value) do
    is_key_missed = !Map.has_key?(expected_map_value, field.key)

    if is_key_missed do
      is_optional
    else
      Talos.valid?(field.type, expected_map_value[field.key])
    end
  end

  def valid?(_field, _not_map_value) do
    false
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

  def errors(_field, _not_map_value) do
    false
  end
end

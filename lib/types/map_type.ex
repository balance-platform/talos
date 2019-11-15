defmodule Talos.Types.MapType do
  defstruct [:fields]

  @behaviour Talos.Types

  @default_options [optional: false, allow_nil: false]

  def valid?(%__MODULE__{fields: nil}, value) do
    is_map(value)
  end

  def valid?(%__MODULE__{fields: fields}, value) do
    is_map(value) &&
      Enum.all?(fields, fn field ->
        case field do
          {key, %{__struct__: type_module} = type} ->
            validation_check(type_module, type, value, key, @default_options)

          {key, %{__struct__: type_module} = type, options} ->
            validation_check(type_module, type, value, key, options)
        end
      end)
  end

  defp validation_check(module, type, map, key, options) do
    cond do
      options[:optional] && !Map.has_key?(map, key) -> true
      !options[:optional] && !Map.has_key?(map, key) -> false
      Map.has_key?(map, key) && options[:allow_nil] && is_nil(map[key]) -> true
      Map.has_key?(map, key) && !options[:allow_nil] && is_nil(map[key]) -> false
      true -> module.valid?(type, map[key])
    end
  end
end

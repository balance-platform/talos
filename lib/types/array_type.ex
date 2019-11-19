defmodule Talos.Types.ArrayType do
  @moduledoc false
  defstruct [:type]

  @behaviour Talos.Types

  def valid?(%__MODULE__{type: type}, values) do
    is_list(values) &&
      Enum.all?(values, fn value ->
        valid_value?(type, value)
      end)
  end

  def errors(%__MODULE__{type: element_type} = array_type, values) do
    cond do
      !is_list(values) -> [value: values]
      !valid?(array_type, values) -> return_only_errors(element_type, values)
      true -> []
    end
  end

  defp return_only_errors(element_type, values) do
    errors =
      values
      |> Enum.reject(fn val ->
        valid_value?(element_type, val)
      end)

    case errors == [] do
      true -> []
      false -> [value: errors]
    end
  end

  defp valid_value?(nil = _element_type, _value) do
    true
  end

  defp valid_value?(%{__struct__: module} = type_description, value) do
    module.valid?(type_description, value)
  end
end

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
      !is_list(values) ->
        ["#{inspect(values)} does not match #{inspect(array_type)}"]

      !valid?(array_type, values) ->
        return_only_errors(element_type, values)

      true ->
        []
    end
  end

  defp return_only_errors(element_type, values) do
    values
    |> Enum.reject(fn val -> valid_value?(element_type, val) end)
    |> Enum.map(fn element -> element_errors(element_type, element) end)
    |> List.flatten()
  end

  defp valid_value?(nil = _element_type, _value) do
    true
  end

  defp valid_value?(type_description, value) do
    Talos.valid?(type_description, value)
  end

  defp element_errors(type_description, value) do
    Talos.errors(type_description, value)
  end
end

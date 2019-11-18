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

  defp valid_value?(nil = _type_description, _value) do
    true
  end

  defp valid_value?(%{__struct__: module} = type_description, value) do
    module.valid?(type_description, value)
  end
end

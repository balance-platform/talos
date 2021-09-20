defmodule Talos.Types.ConstType do
  @moduledoc """
  Constant value validation
  """
  defstruct value: nil, description: nil
  @behaviour Talos.Types

  @type t :: %__MODULE__{value: any}

  def valid?(%__MODULE__{value: value_expected}, value) do
    case value_expected == value do
      true -> true
      false -> false
    end
  end

  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> ["#{inspect(value)} should be equal #{inspect(type.value)}"]
    end
  end
end

defmodule Talos.Types.FloatType do
  defstruct [:gteq, :lteq, :gt, :lt]
  alias Talos.Types.NumberType
  @behaviour Talos.Types

  def valid?(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt}, value) do
    NumberType.valid?(
      %NumberType{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: :float},
      value
    )
  end

  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> [value: value]
    end
  end
end

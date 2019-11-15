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
end

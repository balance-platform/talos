defmodule Talos.Types.IntegerType do
  alias Talos.Types.NumberType
  defstruct [:gteq, :lteq, :gt, :lt]
  @behaviour Talos.Types

  def valid?(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt}, value) do
    NumberType.valid?(
      %NumberType{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: :integer},
      value
    )
  end
end

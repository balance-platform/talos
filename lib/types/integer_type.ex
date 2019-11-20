defmodule Talos.Types.IntegerType do
  @moduledoc false
  alias Talos.Types.NumberType
  defstruct [:gteq, :lteq, :gt, :lt]
  @behaviour Talos.Types

  def valid?(type, value) do
    type
    |> wrap_type()
    |> NumberType.valid?(value)
  end

  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end

  defp wrap_type(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt}) do
    %NumberType{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: :integer}
  end
end

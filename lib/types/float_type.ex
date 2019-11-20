defmodule Talos.Types.FloatType do
  @moduledoc false
  defstruct [:gteq, :lteq, :gt, :lt]
  alias Talos.Types.NumberType
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
    %NumberType{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: :float}
  end
end

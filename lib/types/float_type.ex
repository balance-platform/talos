defmodule Talos.Types.FloatType do
  @moduledoc """
  Type for check value is float

  For example:
  ```elixir
    percents = %Talos.Types.FloatType{gteq: 0, lteq: 100}

    Talos.valid?(percents, 42.0) #=> true
    Talos.valid?(percents, 136.0) #=> false
  ```

  Additional parameters:

  `gteq` - greater than or equal, same as `>=`

  `lteq` - lower than or equal, same as `<=`

  `gt` - lower than, same as `>`

  `lt` - lower than, same as `<`
  """
  defstruct [:gteq, :lteq, :gt, :lt]

  @type t :: %{
          __struct__: atom,
          gteq: float,
          lteq: float,
          gt: float,
          lt: float
        }

  alias Talos.Types.NumberType
  @behaviour Talos.Types

  @spec valid?(Talos.Types.FloatType.t(), any) :: boolean
  def valid?(type, value) do
    type
    |> wrap_type()
    |> NumberType.valid?(value)
  end

  @spec errors(Talos.Types.FloatType.t(), any) :: list(String.t())
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

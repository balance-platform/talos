defmodule Talos.Types.IntegerType do
  @moduledoc """
  Type for check value is integer

  For example:
  ```elixir
    percents = %Talos.Types.IntegerType{gteq: 0, lteq: 100}

    Talos.valid?(percents, 42) #=> true
    Talos.valid?(percents, -15) #=> false
    Talos.valid?(percents, 30.0) #=> false (becouse value is float)
  ```

  Additional parameters:

  `gteq` - greater than or equal, same as `>=`

  `lteq` - lower than or equal, same as `<=`

  `gt` - lower than, same as `>`

  `lt` - lower than, same as `<`
  """
  alias Talos.Types.NumberType
  defstruct [:gteq, :lteq, :gt, :lt]

  @type t :: %{
          __struct__: atom,
          gteq: integer,
          lteq: integer,
          gt: integer,
          lt: integer
        }
  @behaviour Talos.Types

  @spec valid?(Talos.Types.IntegerType.t(), any) :: boolean
  def valid?(type, value) do
    type
    |> wrap_type()
    |> NumberType.valid?(value)
  end

  @spec errors(Talos.Types.IntegerType.t(), any) :: list(String.t())
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

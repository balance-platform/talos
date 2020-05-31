defmodule Talos.Types.IntegerType do
  @moduledoc """
  Type for check value is integer

  For example:
  ```elixir
    
    iex> percents = %Talos.Types.IntegerType{gteq: 0, lteq: 100}
    iex> Talos.valid?(percents, 42)
    true
    iex> Talos.valid?(percents, -15)
    false
    iex> Talos.valid?(percents, 30.0)
    false

  ```

  Additional parameters:

  `allow_nil` - allows value to be nil

  `allow_blank` - allows value to be blank (0)

  `gteq` - greater than or equal, same as `>=`

  `lteq` - lower than or equal, same as `<=`

  `gt` - lower than, same as `>`

  `lt` - lower than, same as `<`
  """
  alias Talos.Types.NumberType
  defstruct [:gteq, :lteq, :gt, :lt, allow_nil: false, example_value: nil, allow_blank: false]

  @type t :: %{
          __struct__: atom,
          gteq: nil | integer,
          lteq: nil | integer,
          gt: nil | integer,
          lt: nil | integer,
          allow_blank: boolean,
          allow_nil: boolean,
          example_value: any
        }
  @behaviour Talos.Types

  @spec valid?(Talos.Types.IntegerType.t(), any) :: boolean
  def valid?(module, value) do
    errors(module, value) == []
  end

  def errors(%__MODULE__{allow_blank: true}, 0) do
    []
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    []
  end

  def errors(type, value) do
    type
    |> wrap_type()
    |> NumberType.errors(value)
  end

  defp wrap_type(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt}) do
    %NumberType{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: :integer}
  end
end

defmodule Talos.Types.NumberType do
  @moduledoc """
  Type for check value is number

  For example:
  ```elixir

    iex> percents = %Talos.Types.NumberType{gteq: 0, lteq: 100}
    iex> Talos.valid?(percents, 42)
    true
    iex> Talos.valid?(percents, -15)
    false
    iex> Talos.valid?(percents, 30.0)
    true

  ```

  Additional parameters:

  `allow_nil` - allows value to be nil

  `gteq` - greater than or equal, same as `>=`

  `lteq` - lower than or equal, same as `<=`

  `gt` - lower than, same as `>`

  `lt` - lower than, same as `<`

  """
  defstruct [:gteq, :lteq, :gt, :lt, :type, allow_nil: false]
  @behaviour Talos.Types

  @type t :: %{
          __struct__: atom,
          gteq: nil | number,
          lteq: nil | number,
          gt: nil | number,
          lt: nil | number,
          allow_nil: boolean,
          type: :float | :integer | nil
        }

  @spec valid?(Talos.Types.NumberType.t(), any) :: boolean
  def valid?(%__MODULE__{allow_nil: true}, nil) do
    true
  end

  def valid?(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: type}, value)
      when type in [nil, :float, :integer] do
    with true <- check_type(type, value),
         true <- is_nil(lt) || value < lt,
         true <- is_nil(gt) || value > gt,
         true <- is_nil(gteq) || value >= gteq,
         true <- is_nil(lteq) || value <= lteq do
      true
    else
      false -> false
    end
  end

  @spec errors(Talos.Types.NumberType.t(), binary) :: list(String.t())
  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end

  defp check_type(nil, value) do
    is_float(value) || is_integer(value)
  end

  defp check_type(:integer, value) do
    is_integer(value)
  end

  defp check_type(:float, value) do
    is_float(value)
  end
end

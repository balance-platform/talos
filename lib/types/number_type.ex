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
  defstruct [:gteq, :lteq, :gt, :lt, :type, allow_nil: false, example_value: nil]
  @behaviour Talos.Types

  @type t :: %{
          __struct__: atom,
          gteq: nil | number,
          lteq: nil | number,
          gt: nil | number,
          lt: nil | number,
          allow_nil: boolean,
          example_value: any,
          type: :float | :integer | nil
        }

  @spec valid?(Talos.Types.NumberType.t(), any) :: boolean
  def valid?(type, value) do
    errors(type, value) == []
  end

  @spec errors(Talos.Types.NumberType.t(), binary) :: list(String.t())
  def errors(%__MODULE__{allow_nil: true}, nil) do
    []
  end

  def errors(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: type}, value) do
    errors =
      case check_type(type, value) do
        true ->
          [
            {is_nil(lt) || value < lt, "should be lower than #{lt}"},
            {is_nil(gt) || value > gt, "should be greater than #{gt}"},
            {is_nil(gteq) || value >= gteq, "should be greater than or equal to #{gteq}"},
            {is_nil(lteq) || value <= lteq, "should be lower than or equal to #{lteq}"}
          ]
          |> Enum.filter(fn {bool, _} -> bool == false end)
          |> Enum.map(fn {_, error_text} -> error_text end)

        false ->
          ["should be #{type || "float or integer"} type"]
      end

    case errors == [] do
      true -> []
      false -> [inspect(value)] ++ errors
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

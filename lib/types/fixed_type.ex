defmodule Talos.Types.FixedType do
  @moduledoc ~S"""
  Fixed type is used to check value to be equal expected

  For example:
  ```elixir
    
    iex> the_4th_planet = %Talos.Types.FixedType{value: "Mars"}
    iex> Talos.valid?(the_4th_planet, "Earth")
    false
    iex> Talos.valid?(the_4th_planet, "Mars")
    true
    
  ```


  Additional parameters:
  `allow_nil` - allows value to be nil
  """
  defstruct [:value, allow_nil: false, example_value: nil]

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          example_value: any
        }

  @behaviour Talos.Types

  @spec valid?(Talos.Types.FixedType.t(), any) :: boolean
  def valid?(type, value) do
    errors(type, value) == []
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    []
  end

  def errors(%__MODULE__{value: expected_value} = expected, value) do
    case expected_value == value do
      true -> []
      false -> [inspect(value), "Should be #{inspect(expected)}"]
    end
  end
end

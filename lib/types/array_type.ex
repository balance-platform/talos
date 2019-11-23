defmodule Talos.Types.ArrayType do
  @moduledoc """
    ArrayType is used to check passed value is a list

  ```elixir
    iex> alias Talos.Types.ArrayType
    iex> alias Talos.Types.IntegerType
    iex> Talos.valid?(%ArrayType{allow_blank: true}, [])
    true
    iex> Talos.valid?(%ArrayType{allow_nil: true}, nil)
    true
    iex> Talos.valid?(%ArrayType{}, nil)
    false
    iex> Talos.valid?(%ArrayType{}, ["one", two, 3, %{}])
    true
    iex> Talos.valid?(%ArrayType{type: %IntegerType{}}, ["one", two, 3, %{}])
    false
    iex> Talos.valid?(%ArrayType{type: %IntegerType{}}, [1,2,3])
    true
    iex> Talos.valid?(%ArrayType{type: %IntegerType{allow_nil: true}}, [nil,2,3])
    true

  ```

  Additional parameters:

  `allow_blank` - allows array to be empty

  `allow_nil` - allows value to be nil

  `type` - defines type of array elements

  """
  defstruct [:type, allow_nil: false, allow_blank: false]

  @behaviour Talos.Types
  @type t :: %{
          __struct__: atom,
          type: struct | module | nil,
          allow_blank: boolean,
          allow_nil: boolean
        }
  @spec valid?(Talos.Types.ArrayType.t(), any) :: boolean
  def valid?(%__MODULE__{allow_blank: true}, []) do
    true
  end

  def valid?(%__MODULE__{allow_nil: true}, nil) do
    true
  end

  def valid?(%__MODULE__{type: type}, values) do
    is_list(values) &&
      Enum.all?(values, fn value ->
        valid_value?(type, value)
      end)
  end

  @spec errors(Talos.Types.ArrayType.t(), any) :: list(String.t())
  def errors(%__MODULE__{type: element_type} = array_type, values) do
    cond do
      !is_list(values) ->
        ["#{inspect(values)} does not match #{inspect(array_type)}"]

      !valid?(array_type, values) ->
        return_only_errors(element_type, values)

      true ->
        []
    end
  end

  defp return_only_errors(element_type, values) do
    values
    |> Enum.reject(fn val -> valid_value?(element_type, val) end)
    |> Enum.map(fn element -> element_errors(element_type, element) end)
    |> List.flatten()
  end

  defp valid_value?(nil = _element_type, _value) do
    true
  end

  defp valid_value?(type_description, value) do
    Talos.valid?(type_description, value)
  end

  defp element_errors(type_description, value) do
    Talos.errors(type_description, value)
  end
end

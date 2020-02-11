defmodule Talos.Types.ListType do
  @moduledoc """
    ListType is used to check passed value is a list

  ```elixir
    iex> alias Talos.Types.ListType
    iex> alias Talos.Types.IntegerType
    iex> Talos.valid?(%ListType{allow_blank: true}, [])
    true
    iex> Talos.valid?(%ListType{allow_nil: true}, nil)
    true
    iex> Talos.valid?(%ListType{}, nil)
    false
    iex> Talos.valid?(%ListType{}, ["one", two, 3, %{}])
    true
    iex> Talos.valid?(%ListType{type: %IntegerType{}}, ["one", two, 3, %{}])
    false
    iex> Talos.valid?(%ListType{type: %IntegerType{}}, [1,2,3])
    true
    iex> Talos.valid?(%ListType{type: %IntegerType{allow_nil: true}}, [nil,2,3])
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
  @spec valid?(Talos.Types.ListType.t(), any) :: boolean
  def valid?(module, value) do
    errors(module, value) == []
  end

  @spec errors(Talos.Types.ListType.t(), any) :: list(String.t())
  def errors(%__MODULE__{allow_blank: true}, []) do
    []
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    []
  end

  def errors(%__MODULE__{type: element_type} = _array_type, values) do
    case is_list(values) do
      true ->
        return_only_errors(element_type, values)

      false ->
        [inspect(values), "should be ListType"]
    end
  end

  defp return_only_errors(element_type, values) do
    values
    |> Enum.map(fn val -> element_errors(element_type, val) end)
    |> Enum.reject(fn element -> element in [%{}, []] end)
  end

  defp element_errors(nil = _type_description, _value) do
    []
  end

  defp element_errors(type_description, value) do
    Talos.errors(type_description, value)
  end
end

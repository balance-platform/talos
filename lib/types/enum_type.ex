defmodule Talos.Types.EnumType do
  @moduledoc ~S"""
  Enum type is used to check value to be one of enumerable

  For example:
  ```elixir
    
    iex> genders = %Talos.Types.EnumType{members: ["male", "female"]}
    iex> Talos.valid?(genders, "male")
    true
    iex> Talos.valid?(genders, "female")
    true
    iex> Talos.valid?(genders, "heli")
    false

  ```


  Also there can be another Talos types:
  ```elixir

    iex> digit_string = %Talos.Types.StringType{regexp: ~r/^\d+$/}
    iex> numbers = %Talos.Types.EnumType{members: [digit_string, %Talos.Types.IntegerType{}]}
    iex> Talos.valid?(numbers, "1")
    true
    iex> Talos.valid?(numbers, 1)
    true
    iex> Talos.valid?(numbers, "One")
    false

  ```


  Additional parameters:

  `allow_nil` - allows value to be nil

  `members` - list of possible values or TalosTypes

  """
  defstruct [:members, allow_nil: false]

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          members: maybe_improper_list
        }

  @behaviour Talos.Types

  @spec valid?(Talos.Types.EnumType.t(), any) :: boolean
  def valid?(%__MODULE__{allow_nil: true}, nil) do
    true
  end

  def valid?(%__MODULE__{members: members}, value) when is_list(members) do
    value in members ||
      Enum.any?(members, fn something ->
        check_if_value_is_valid_typed(something, value)
      end)
  end

  @spec errors(Talos.Types.EnumType.t(), any) :: list(String.t())
  def errors(type, value) do
    case valid?(type, value) do
      true ->
        []

      false ->
        ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end

  defp check_if_value_is_valid_typed(%module{} = maybe_type, value) do
    # preload for function_exported?
    Code.ensure_loaded(module)
    
    case function_exported?(module, :valid?, 2) do
      true -> Talos.valid?(maybe_type, value)
      false -> false
    end
  end

  defp check_if_value_is_valid_typed(_something, _value) do
    false
  end
end

defmodule Talos.Types.EnumType do
  @moduledoc ~S"""
  Enum type is used to check value to be one of enumerable

  For example:
  ```elixir
    iex> import Talos
    iex> genders = enum(members: ["male", "female"])
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
  defstruct [:members, allow_nil: false, example_value: nil]

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          members: maybe_improper_list,
          example_value: any
        }

  @behaviour Talos.Types

  @spec valid?(Talos.Types.EnumType.t(), any) :: boolean
  def valid?(type, value) do
    errors(type, value) == []
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    []
  end

  def errors(%__MODULE__{members: members}, value) when is_list(members) do
    case value in members do
      true ->
        []

      false ->
        errors =
          members
          |> Enum.map(fn something ->
            errors_for_members(something, value)
          end)

        case Enum.any?(errors, fn error -> error in [%{}, []] end) do
          true -> []
          false -> errors
        end
    end
  end

  defp errors_for_members(%module{} = maybe_type, value) do
    # preload for function_exported?
    Code.ensure_loaded(module)

    case function_exported?(module, :errors, 2) do
      true -> Talos.errors(maybe_type, value)
      false -> [inspect(value), "should be #{module}"]
    end
  end

  defp errors_for_members(something, _value) do
    "allowed value is #{inspect(something)}"
  end
end

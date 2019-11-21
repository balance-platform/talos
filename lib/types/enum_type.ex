defmodule Talos.Types.EnumType do
  @moduledoc """
  Enum type is used to check value to be one of enumerable

  For example:
  ```elixir
    genders = %Talos.Types.EnumType{members: ["male", "female"]}

    Talos.valid?(genders, user.gender) #=> true/false
  ```
  """
  defstruct [:members]

  @type t :: %{
          __struct__: atom,
          members: maybe_improper_list
        }

  @behaviour Talos.Types

  @spec valid?(Talos.Types.EnumType.t(), any) :: boolean
  def valid?(%__MODULE__{members: members}, value) when is_list(members) do
    value in members
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
end

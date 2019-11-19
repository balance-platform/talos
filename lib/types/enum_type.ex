defmodule Talos.Types.EnumType do
  @moduledoc false
  defstruct [:members]
  @behaviour Talos.Types

  def valid?(%__MODULE__{members: members}, value) when is_list(members) do
    value in members
  end

  def errors(type, value) do
    case valid?(type, value) do
      true ->
        []

      false ->
        ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end
end

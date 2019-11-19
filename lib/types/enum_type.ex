defmodule Talos.Types.EnumType do
  defstruct [:members]
  @behaviour Talos.Types

  def valid?(%__MODULE__{members: members}, value) when is_list(members) do
    value in members
  end

  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> [value: value]
    end
  end
end

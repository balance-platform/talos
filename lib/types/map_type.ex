defmodule Talos.Types.MapType do
  defstruct []
  @behaviour Talos.Types

  def valid?(%__MODULE__{}, value) do
    is_map(value)
  end
end

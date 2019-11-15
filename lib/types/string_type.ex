defmodule Talos.Types.StringType do
  defstruct regexp: nil
  @behaviour Talos.Types

  def valid?(%__MODULE__{regexp: nil}, value) do
    String.valid?(value)
  end

  def valid?(%__MODULE__{regexp: regexp}, value) do
    String.valid?(value) && Regex.match?(regexp, value)
  end
end

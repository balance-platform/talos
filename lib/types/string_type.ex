defmodule Talos.Types.StringType do
  @moduledoc false
  defstruct [:min_length, :length, :max_length, :regexp]
  @behaviour Talos.Types

  def valid?(
        %__MODULE__{regexp: regexp, min_length: min_len, length: len, max_length: max_len},
        value
      ) do
    with true <- String.valid?(value),
         str_len <- String.length(value),
         true <- is_nil(min_len) || min_len <= str_len,
         true <- is_nil(len) || len == str_len,
         true <- is_nil(max_len) || str_len <= max_len,
         true <- is_nil(regexp) || Regex.match?(regexp, value) do
      true
    else
      false -> false
    end
  end

  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end
end

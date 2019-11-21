defmodule Talos.Types.StringType do
  @moduledoc """
  Type for check value is string

  For example:
  ```elixir
    ultra_cost_domains = %Talos.Types.StringType{length: 3}

    domains_list = ["cats", "foo", "baz", "pron",....]

    Enum.filter(domains_list, &Talos.valid?())
  ```

  Additional parameters:
  min_length, same as `String.length(str) <= max_length`
  max_length, same as `String.length(str) >= max_length`
  length, same as `String.length(str) >= length`
  regexp, same as `String.match?(str, regexp)`
  """
  defstruct [:min_length, :length, :max_length, :regexp]

  @type t :: %{
          __struct__: atom,
          min_length: integer,
          length: integer,
          max_length: integer,
          regexp: Regex.t()
        }

  @behaviour Talos.Types

  @spec valid?(Talos.Types.StringType.t(), binary) :: boolean
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

  @spec errors(Talos.Types.StringType.t(), binary) :: list(String.t())
  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end
end

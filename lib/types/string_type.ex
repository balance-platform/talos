defmodule Talos.Types.StringType do
  @moduledoc """
  Type for check value is string

  For example:
  ```elixir
    iex> import Talos, only: [string: 1]
    iex> short_domain = string(length: 3)
    iex> domains_list = ["cats", "foo", "baz", "pron"]
    iex> Enum.filter(domains_list, fn str -> Talos.valid?(short_domain, str) end)
    ["foo", "baz"]

  ```

  Additional parameters:

  `min_length`, same as `String.length(str) <= max_length`

  `max_length`, same as `String.length(str) >= max_length`

  `length`, same as `String.length(str) >= length`

  `regexp`, same as `String.match?(str, regexp)`

  """
  defstruct [
    :min_length,
    :length,
    :max_length,
    :regexp,
    allow_nil: false,
    allow_blank: false,
    example_value: nil
  ]

  @type t :: %{
          __struct__: atom,
          min_length: nil | integer,
          length: nil | integer,
          max_length: nil | integer,
          allow_nil: nil | boolean,
          allow_blank: nil | boolean,
          regexp: nil | Regex.t(),
          example_value: any
        }

  @behaviour Talos.Types

  @spec valid?(Talos.Types.StringType.t(), any) :: boolean
  def valid?(type, value) do
    errors(type, value) == []
  end

  @spec errors(Talos.Types.StringType.t(), binary) :: list(String.t())
  def errors(%__MODULE__{allow_blank: true}, "") do
    []
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    []
  end

  def errors(
        %__MODULE__{regexp: regexp, min_length: min_len, length: len, max_length: max_len},
        value
      ) do
    errors =
      case String.valid?(value) do
        true ->
          str_len = String.length(value)

          [
            {is_nil(min_len) || min_len <= str_len, "minimum length: #{min_len}"},
            {is_nil(len) || len == str_len, "length should be equal #{len}"},
            {is_nil(max_len) || str_len <= max_len, "maximum length #{max_len}"},
            {is_nil(regexp) || Regex.match?(regexp, value),
             "should match given regexp #{inspect(regexp)}"}
          ]
          |> Enum.filter(fn {bool, _} -> bool == false end)
          |> Enum.map(fn {_, error_text} -> error_text end)

        false ->
          ["should be StringType"]
      end

    case errors == [] do
      true -> []
      false -> [inspect(value)] ++ errors
    end
  end
end

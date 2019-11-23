defmodule Talos.Types do
  @moduledoc """
  Talos Type behaviour

  You can implement your own data type and use it with another Talos Types

  ```elixir

    iex> defmodule EmailType do
    iex>   @behaviour Talos.Types
    iex>   alias Talos.Types.StringType
    iex>   @email_type %StringType{min_length: 5, regexp: ~r/.*@.*/, max_length: 255}
    iex>   def valid?(_email_type, email) do
    iex>     Talos.valid?(@email_type, email)
    iex>   end
    iex>   def errors(email_type, email) do
    iex>     case valid?(email_type, email) do
    iex>       true -> []
    iex>       false -> ["not valid email"]
    iex>     end
    iex>   end
    iex> end
    iex> Talos.valid?(EmailType, "example@foo.ru")
    true
    iex> Talos.valid?(EmailType, "example")
    false
    iex> Talos.errors(EmailType, "example@foo.ru")
    []
    iex> Talos.errors(EmailType, "example")
    ["not valid email"]

  ```
  """
  @callback valid?(struct | module, any) :: boolean
  @callback errors(struct | module, any) :: list(String.t()) | map
end

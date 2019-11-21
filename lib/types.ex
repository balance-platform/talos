defmodule Talos.Types do
  @moduledoc """
  Talos Type behaviour

  You can implement your own data type and use it with another Talos Types

  ```elixir
  defmodule EmailType do
    @behaviour Talos.Types
    alias Talos.Types.StringType

    @email_type %StringType{min_length: 5, regexp: ~r/.*@.*/, max_length: 255}

    def valid?(_email_type, email) do
      Talos.valid?(@email_type, email)
    end

    def errors(email_type, email) do
      case valid?(email_type, email) do
        true -> []
        false -> ["\#{inspect(email)} is not valid email"]
      end
    end
  end

  Talos.valid?(%EmailType, "example@foo.ru") #=> true
  Talos.valid?(%EmailType, "example") #=> false

  Talos.errors(%EmailType, "example@foo.ru") #=> []
  Talos.errors(%EmailType, "example") #=> ["example is not valid email"]
  ```
  """
  @callback valid?(any, any) :: boolean
  @callback errors(any, any) :: list(String.t()) | map
end

defmodule Talos.Types.BooleanType do
  @moduledoc """
  Boolean type is used to check value is boolean

  For example:
  ```elixir
    iex> import Talos, only: [boolean: 1]
    iex> shoud_be_boolean = boolean(allow_nil: false)
    iex> Talos.valid?(shoud_be_boolean, 2 == 2)
    true
    iex> Talos.valid?(shoud_be_boolean, "true")
    false

  ```

  Additional parameters:

  `allow_nil` - allows value to be nil
  """
  defstruct allow_nil: false

  @type t :: %{
          __struct__: any,
          allow_nil: boolean
        }

  @behaviour Talos.Types

  def valid?(%__MODULE__{allow_nil: allow_nil}, value) do
    case allow_nil do
      true -> is_nil(value) || is_boolean(value)
      false -> is_boolean(value)
    end
  end

  def errors(type, value) do
    case valid?(type, value) do
      true -> []
      false -> ["#{inspect(value)} does not match type #{inspect(type)}"]
    end
  end
end

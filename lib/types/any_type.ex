defmodule Talos.Types.AnyType do
  @moduledoc """
  Any type is used to show that data doesn't have a constant type

  For example:
  ```elixir
    iex> import Talos, only: [any: 1]
    iex> could_be_any_type = any()
    iex> Talos.valid?(could_be_any_type, 2 == 2)
    true
    iex> Talos.valid?(could_be_any_type, nil)
    true
    iex> Talos.valid?(could_be_any_type, "123")
    true
  ```
  """

  @behaviour Talos.Types
  # Type must be struct, even empty
  defstruct []

  @type t :: %{
          __struct__: any
        }

  @spec valid?(struct | module, any) :: true
  def valid?(_, _), do: true

  @spec errors(struct | module, any) :: []
  def errors(_, _), do: []
end

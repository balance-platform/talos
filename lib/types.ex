defmodule Talos.Types do
  @moduledoc """

  """

  @callback valid?(any, any) :: boolean
  @callback errors(any, any) :: list
end

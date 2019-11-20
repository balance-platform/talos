defmodule Talos.Types do
  @moduledoc false
  @callback valid?(any, any) :: boolean
  @callback errors(any, any) :: list(String.t()) | map
end

defmodule Talos.Field do
  @enforce_keys [:name, :type]

  defstruct name: nil, type: nil, description: nil, default: nil, required: false
end

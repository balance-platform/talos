defmodule Talos do
  @moduledoc """
  Documentation for Talos.
  """

  def valid?(%{__struct__: type_module} = data_type, data) do
    type_module.valid?(data_type, data)
  end
end

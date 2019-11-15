defmodule Talos.Types.MapTypeTest do
  use ExUnit.Case
  alias Talos.Types.MapType

  test "#valid?" do
    assert false == MapType.valid?(%MapType{}, 5)
    assert false == MapType.valid?(%MapType{}, 0)
    assert false == MapType.valid?(%MapType{}, "e")
    assert false == MapType.valid?(%MapType{}, "z")
    assert true == MapType.valid?(%MapType{}, %{})
  end
end

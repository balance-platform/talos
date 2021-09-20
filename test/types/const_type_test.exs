defmodule Types.ConstTypeTest do
  use ExUnit.Case
  alias Talos.Types.ConstType

  test "#valid?" do
    assert ConstType.valid?(%ConstType{value: true}, true)
    assert ConstType.valid?(%ConstType{value: true}, false) == false
    assert ConstType.valid?(%ConstType{value: "abc"}, "ABC") == false
    assert ConstType.valid?(%ConstType{value: "abc"}, "abc") == true
  end
end

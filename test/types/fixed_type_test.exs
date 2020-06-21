defmodule Talos.Types.FixedTypeTest do
  use ExUnit.Case
  alias Talos.Types.FixedType

  doctest FixedType

  test "#valid?" do
    assert true == FixedType.valid?(%FixedType{value: "A"}, "A")
    assert false == FixedType.valid?(%FixedType{value: "A"}, "B")
    assert false == FixedType.valid?(%FixedType{value: "A"}, nil)
    assert true == FixedType.valid?(%FixedType{value: "A", allow_nil: true}, nil)
  end

  test "errors - returns list with error element" do
    assert [] == FixedType.errors(%FixedType{value: "A"}, "A")
    assert [_b, _should_be_eq_to_type] = FixedType.errors(%FixedType{value: "A"}, "B")
  end
end

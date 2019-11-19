defmodule Talos.Types.NumberTypeTest do
  use ExUnit.Case
  alias Talos.Types.NumberType

  test "#valid? - with additional params" do
    assert true == NumberType.valid?(%NumberType{lt: 3}, 1)
    assert false == NumberType.valid?(%NumberType{lt: 0}, 1)
    assert false == NumberType.valid?(%NumberType{lt: 0}, 0)

    assert true == NumberType.valid?(%NumberType{gt: 2}, 10)
    assert false == NumberType.valid?(%NumberType{gt: 2}, 0)
    assert false == NumberType.valid?(%NumberType{gt: 2}, 2)

    assert true == NumberType.valid?(%NumberType{gteq: 0}, 0)
    assert true == NumberType.valid?(%NumberType{gteq: 0}, 10)
    assert false == NumberType.valid?(%NumberType{gteq: 0}, -10)

    assert false == NumberType.valid?(%NumberType{lteq: 42}, 100)
    assert true == NumberType.valid?(%NumberType{lteq: 42.0}, 42)
    assert true == NumberType.valid?(%NumberType{lteq: 42}, 0)
  end

  test "#valid? - default params" do
    assert true == NumberType.valid?(%NumberType{}, 1)
    assert true == NumberType.valid?(%NumberType{}, 1.0)
    assert false == NumberType.valid?(%NumberType{type: :integer}, 1.0)
    assert false == NumberType.valid?(%NumberType{}, "String")
    assert false == NumberType.valid?(%NumberType{}, %{})
    assert false == NumberType.valid?(%NumberType{}, nil)
    assert false == NumberType.valid?(%NumberType{}, DateTime.utc_now())
    assert false == NumberType.valid?(%NumberType{}, [])
  end

  test "#errors - default params" do
    assert [] == NumberType.errors(%NumberType{}, 1)
    assert [] == NumberType.errors(%NumberType{}, 1.0)

    assert [_error_message] = NumberType.errors(%NumberType{type: :integer}, 1.0)
    assert [_error_message] = NumberType.errors(%NumberType{}, "String")
    assert [_error_message] = NumberType.errors(%NumberType{}, %{})
    assert [_error_message] = NumberType.errors(%NumberType{}, nil)
    assert [_error_message] = NumberType.errors(%NumberType{}, DateTime.utc_now())
    assert [_error_message] = NumberType.errors(%NumberType{}, [])
  end

  test "#valid? - called with wrong type" do
    assert_raise FunctionClauseError, fn -> NumberType.valid?(%NumberType{type: :string}, 42) end
  end
end

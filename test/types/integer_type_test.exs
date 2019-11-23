defmodule Talos.Types.IntegerTest do
  use ExUnit.Case
  alias Talos.Types.IntegerType
  doctest IntegerType

  test "#valid? - with additional params" do
    assert true == IntegerType.valid?(%IntegerType{allow_nil: true}, nil)
    assert true == IntegerType.valid?(%IntegerType{lt: 3}, 1)
    assert false == IntegerType.valid?(%IntegerType{lt: 0}, 1)
    assert false == IntegerType.valid?(%IntegerType{lt: 0}, 0)

    assert true == IntegerType.valid?(%IntegerType{gt: 2}, 10)
    assert false == IntegerType.valid?(%IntegerType{gt: 2}, 0)
    assert false == IntegerType.valid?(%IntegerType{gt: 2}, 2)

    assert true == IntegerType.valid?(%IntegerType{gteq: 0}, 0)
    assert true == IntegerType.valid?(%IntegerType{gteq: 0}, 10)
    assert false == IntegerType.valid?(%IntegerType{gteq: 0}, -10)

    assert false == IntegerType.valid?(%IntegerType{lteq: 42}, 100)
    assert true == IntegerType.valid?(%IntegerType{lteq: 42}, 42)
    assert true == IntegerType.valid?(%IntegerType{lteq: 42}, 0)
  end

  test "#valid? with allow_blank" do
    assert true == IntegerType.valid?(%IntegerType{allow_blank: true}, 0)
  end

  test "#valid? - default params" do
    assert true == IntegerType.valid?(%IntegerType{}, 1)
    assert false == IntegerType.valid?(%IntegerType{}, 1.0)
    assert false == IntegerType.valid?(%IntegerType{}, "String")
    assert false == IntegerType.valid?(%IntegerType{}, %{})
    assert false == IntegerType.valid?(%IntegerType{}, nil)
    assert false == IntegerType.valid?(%IntegerType{}, DateTime.utc_now())
    assert false == IntegerType.valid?(%IntegerType{}, [])
  end

  test "#errors - default params" do
    assert [] == IntegerType.errors(%IntegerType{}, 1)
    assert [_error_message] = IntegerType.errors(%IntegerType{}, 1.0)
    assert [_error_message] = IntegerType.errors(%IntegerType{}, "String")
    assert [_error_message] = IntegerType.errors(%IntegerType{}, %{})
    assert [_error_message] = IntegerType.errors(%IntegerType{}, nil)

    assert [_error_message] = IntegerType.errors(%IntegerType{}, DateTime.utc_now())

    assert [_error_message] = IntegerType.errors(%IntegerType{}, [])
  end
end

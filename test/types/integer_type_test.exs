defmodule Talos.Types.IntegerTest do
  use ExUnit.Case
  alias Talos.Types.IntegerType

  test "#valid? - with additional params" do
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

  test "#valid? - default params" do
    assert true == IntegerType.valid?(%IntegerType{}, 1)
    assert false == IntegerType.valid?(%IntegerType{}, 1.0)
    assert false == IntegerType.valid?(%IntegerType{}, "String")
    assert false == IntegerType.valid?(%IntegerType{}, %{})
    assert false == IntegerType.valid?(%IntegerType{}, nil)
    assert false == IntegerType.valid?(%IntegerType{}, DateTime.utc_now())
    assert false == IntegerType.valid?(%IntegerType{}, [])
  end
end

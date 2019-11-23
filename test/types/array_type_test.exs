defmodule Talos.Types.ArrayTypeTest do
  use ExUnit.Case
  alias Talos.Types.ArrayType
  alias Talos.Types.NumberType

  test "#valid?" do
    assert true == ArrayType.valid?(%ArrayType{allow_nil: true}, nil)
    assert true == ArrayType.valid?(%ArrayType{}, [])
    assert true == ArrayType.valid?(%ArrayType{}, [1])
    assert true == ArrayType.valid?(%ArrayType{}, [1, 2, "string"])
    assert true == ArrayType.valid?(%ArrayType{allow_nil: true}, [1, 2, "string"])
    assert false == ArrayType.valid?(%ArrayType{}, nil)
    assert false == ArrayType.valid?(%ArrayType{}, 1)
    assert false == ArrayType.valid?(%ArrayType{}, "string")
  end

  test "#valid? with allow_blank" do
    assert true == ArrayType.valid?(%ArrayType{allow_blank: true}, [])
  end

  test "#valid? - with additional params" do
    number_type = %NumberType{gteq: 0}

    assert true == ArrayType.valid?(%ArrayType{type: number_type}, [])
    assert true == ArrayType.valid?(%ArrayType{type: number_type}, [1])
    assert true == ArrayType.valid?(%ArrayType{type: number_type}, [0, 1, 2])

    assert false == ArrayType.valid?(%ArrayType{type: number_type}, nil)
    assert false == ArrayType.valid?(%ArrayType{type: number_type}, 1)
    assert false == ArrayType.valid?(%ArrayType{type: number_type}, [-1000, 1, 2])
    assert false == ArrayType.valid?(%ArrayType{type: number_type}, ["string"])
  end

  test "#errors - returns errors or empty list" do
    number_type = %NumberType{gteq: 0}

    assert [] == ArrayType.errors(%ArrayType{type: number_type}, [])

    assert [error_msg] = ArrayType.errors(%ArrayType{type: number_type}, 1)
    assert error_msg =~ ~r/1 does not match/
    assert [error_msg1, error_msg2] = ArrayType.errors(%ArrayType{type: number_type}, [-1, -2])
    assert error_msg1 =~ ~r/-1 does not match/
    assert error_msg2 =~ ~r/-2 does not match/
  end
end

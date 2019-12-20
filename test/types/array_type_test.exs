defmodule Talos.Types.ListTypeTest do
  use ExUnit.Case
  alias Talos.Types.ListType
  alias Talos.Types.NumberType

  test "#valid?" do
    assert true == ListType.valid?(%ListType{allow_nil: true}, nil)
    assert true == ListType.valid?(%ListType{}, [])
    assert true == ListType.valid?(%ListType{}, [1])
    assert true == ListType.valid?(%ListType{}, [1, 2, "string"])
    assert true == ListType.valid?(%ListType{allow_nil: true}, [1, 2, "string"])
    assert false == ListType.valid?(%ListType{}, nil)
    assert false == ListType.valid?(%ListType{}, 1)
    assert false == ListType.valid?(%ListType{}, "string")
  end

  test "#valid? with allow_blank" do
    assert true == ListType.valid?(%ListType{allow_blank: true}, [])
  end

  test "#valid? - with additional params" do
    number_type = %NumberType{gteq: 0}

    assert true == ListType.valid?(%ListType{type: number_type}, [])
    assert true == ListType.valid?(%ListType{type: number_type}, [1])
    assert true == ListType.valid?(%ListType{type: number_type}, [0, 1, 2])

    assert false == ListType.valid?(%ListType{type: number_type}, nil)
    assert false == ListType.valid?(%ListType{type: number_type}, 1)
    assert false == ListType.valid?(%ListType{type: number_type}, [-1000, 1, 2])
    assert false == ListType.valid?(%ListType{type: number_type}, ["string"])
  end

  test "#errors - returns errors or empty list" do
    number_type = %NumberType{gteq: 0}

    assert [] == ListType.errors(%ListType{type: number_type}, [])

    assert [error_msg] = ListType.errors(%ListType{type: number_type}, 1)
    assert error_msg =~ ~r/1 does not match/
    assert [error_msg1, error_msg2] = ListType.errors(%ListType{type: number_type}, [-1, -2])
    assert error_msg1 =~ ~r/-1 does not match/
    assert error_msg2 =~ ~r/-2 does not match/
  end
end

defmodule Talos.Types.FloatTypeTest do
  use ExUnit.Case
  alias Talos.Types.FloatType

  test "#valid? - with additional params" do
    assert true == FloatType.valid?(%FloatType{lt: 3}, 1.0)
    assert false == FloatType.valid?(%FloatType{lt: 0}, 1.0)
    assert false == FloatType.valid?(%FloatType{lt: 0.0}, 0.0)

    assert true == FloatType.valid?(%FloatType{gt: 2}, 10.0)
    assert false == FloatType.valid?(%FloatType{gt: 2}, 0.0)
    assert false == FloatType.valid?(%FloatType{gt: 2}, 2.0)

    assert true == FloatType.valid?(%FloatType{gteq: 0.0}, 0.0)
    assert true == FloatType.valid?(%FloatType{gteq: 0}, 10.0)
    assert false == FloatType.valid?(%FloatType{gteq: 0}, -10.0)

    assert false == FloatType.valid?(%FloatType{lteq: 42}, 100.0)
    assert true == FloatType.valid?(%FloatType{lteq: 42}, 42.0)
    assert true == FloatType.valid?(%FloatType{lteq: 42}, 0.0)
  end

  test "#valid? - default params" do
    assert true == FloatType.valid?(%FloatType{}, 1.0)
    assert false == FloatType.valid?(%FloatType{}, 1)
    assert false == FloatType.valid?(%FloatType{}, "String")
    assert false == FloatType.valid?(%FloatType{}, %{})
    assert false == FloatType.valid?(%FloatType{}, nil)
    assert false == FloatType.valid?(%FloatType{}, DateTime.utc_now())
    assert false == FloatType.valid?(%FloatType{}, [])
  end
end

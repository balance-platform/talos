defmodule Types.AnyTypeTest do
  use ExUnit.Case
  alias Talos.Types.AnyType

  test "#valid? - true always" do
    assert AnyType.valid?(%AnyType{}, true)
    assert AnyType.valid?(%AnyType{}, "String")
    assert AnyType.valid?(%AnyType{}, %{a: 1, b: 2, c: %{d: [1, 2, 3]}})
    assert AnyType.valid?(%AnyType{}, nil)
    assert AnyType.valid?(%AnyType{}, [])
    assert AnyType.valid?(%AnyType{}, NaiveDateTime.utc_now())
  end
end

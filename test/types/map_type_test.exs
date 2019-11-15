defmodule Talos.Types.MapTypeTest do
  use ExUnit.Case
  alias Talos.Types.MapType
  alias Talos.Types.StringType
  alias Talos.Types.IntegerType

  test "#valid?" do
    assert false == MapType.valid?(%MapType{}, 5)
    assert false == MapType.valid?(%MapType{}, 0)
    assert false == MapType.valid?(%MapType{}, "e")
    assert false == MapType.valid?(%MapType{}, "z")
    assert true == MapType.valid?(%MapType{}, %{})
  end

  test "#valid? - with fields" do
    schema = %MapType{
      fields: [
        {"name", %StringType{}},
        {"age", %IntegerType{gteq: 18}}
      ]
    }

    assert true == MapType.valid?(schema, %{"name" => "Dmitry", "age" => 37})
    assert false == MapType.valid?(schema, %{})
    assert false == MapType.valid?(schema, %{"name" => "Dmitry Juniour", "age" => 14})
  end

  test "#valid? - with optional fields, that skips unexisting keys, or validate them, if present" do
    schema = %MapType{
      fields: [
        {"name", %StringType{}, optional: true},
        {"age", %IntegerType{gteq: 18}, optional: true}
      ]
    }

    assert true == MapType.valid?(schema, %{})
    assert false == MapType.valid?(schema, %{"age" => "37"})
  end

  test "#valid? - with optional fields, allows nil" do
    schema = %MapType{
      fields: [
        {"name", %StringType{}, optional: false, allow_nil: true},
        {"age", %IntegerType{gteq: 18}, optional: false, allow_nil: true}
      ]
    }

    assert false == MapType.valid?(schema, %{})
    assert false == MapType.valid?(schema, %{"age" => nil})
    assert true == MapType.valid?(schema, %{"age" => nil, "name" => nil})
    assert true == MapType.valid?(schema, %{"age" => nil, "name" => "Dmitry"})
  end
end

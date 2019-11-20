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
    assert true == MapType.valid?(%MapType{}, %{a: 3, b: 4})
  end

  test "#errors for simple cases" do
    assert [_error_message] = MapType.errors(%MapType{}, 5)
    assert [_error_message] = MapType.errors(%MapType{}, 0)
    assert [_error_message] = MapType.errors(%MapType{}, "e")
    assert [_error_message] = MapType.errors(%MapType{}, "z")
    assert %{} == MapType.errors(%MapType{}, %{})
    assert %{} == MapType.errors(%MapType{}, %{a: 3, b: 4})
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

  test "#errors for cases with optional fields" do
    schema = %MapType{
      fields: [
        {"name", %StringType{}, optional: false, allow_nil: true},
        {"age", %IntegerType{gteq: 18}, optional: false, allow_nil: true}
      ]
    }

    assert %{
             "age" => [_error_message1],
             "name" => [_error_message2]
           } = MapType.errors(schema, %{})

    assert %{
             "name" => [_error_message]
           } = MapType.errors(schema, %{"age" => nil})

    assert %{} == MapType.errors(schema, %{"age" => nil, "name" => nil})
    assert %{} == MapType.errors(schema, %{"age" => nil, "name" => "Dmitry"})
  end
end

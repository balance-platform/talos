defmodule Talos.Types.MapTypeTest do
  use ExUnit.Case
  import Talos
  alias Talos.Types.MapType

  doctest MapType

  test "#valid?" do
    assert false == MapType.valid?(map(), 5)
    assert false == MapType.valid?(map(), 0)
    assert false == MapType.valid?(map(), "e")
    assert false == MapType.valid?(map(), "z")
    assert true == MapType.valid?(map(allow_nil: true), nil)
    assert true == MapType.valid?(map(), %{})
    assert true == MapType.valid?(map(), %{a: 3, b: 4})
  end

  test "#valid? with fields" do
    schema =
      map(
        fields: [
          field(key: "key_1", type: string()),
          field(key: "key_2", type: string())
        ]
      )

    assert true == MapType.valid?(schema, %{"key_1" => "Doggy", "key_2" => "Kitty"})
    assert false == MapType.valid?(schema, %{"ABBA" => "NICE", "AK47" => "NOT REALLY"})
  end

  test "#errors for simple cases" do
    assert ["5", _error_message] = MapType.errors(map(), 5)
    assert ["0", _error_message] = MapType.errors(map(), 0)
    assert ["\"e\"", _error_message] = MapType.errors(map(), "e")
    assert ["\"z\"", _error_message] = MapType.errors(map(), "z")
    assert %{} == MapType.errors(map(), %{})
    assert %{} == MapType.errors(map(), %{a: 3, b: 4})
  end

  test "#valid? - with fields" do
    schema =
      map(
        fields: [
          field(key: "name", type: string()),
          field(key: "age", type: integer(gteq: 18))
        ]
      )

    assert true == MapType.valid?(schema, %{"name" => "Dmitry", "age" => 37})
    assert false == MapType.valid?(schema, %{})
    assert false == MapType.valid?(schema, %{"name" => "Dmitry Juniour", "age" => 14})
  end

  test "#valid? - with optional fields, that skips unexisting keys, or validate them, if present" do
    schema =
      map(
        fields: [
          field(key: "name", type: string(), optional: true),
          field(key: "age", type: integer(gteq: 18), optional: true)
        ]
      )

    assert true == MapType.valid?(schema, %{})
    assert false == MapType.valid?(schema, %{"age" => "37"})
  end

  test "#valid? - with required fields, allows nil" do
    schema =
      map(
        fields: [
          field(key: "name", type: string(allow_nil: true), optional: false),
          field(key: "age", type: integer(gteq: 18, allow_nil: true), optional: false)
        ]
      )

    assert false == MapType.valid?(schema, %{})
    assert false == MapType.valid?(schema, %{"age" => nil})
    assert true == MapType.valid?(schema, %{"age" => nil, "name" => nil})
    assert true == MapType.valid?(schema, %{"age" => nil, "name" => "Dmitry"})
  end

  test "#valid? with allow_blank" do
    schema =
      map(
        allow_blank: true,
        fields: [
          field(key: "name", type: string(allow_nil: true), optional: false),
          field(key: "age", type: integer(gteq: 18, allow_nil: true), optional: false)
        ]
      )

    assert false == MapType.valid?(schema, %{"key" => "value"})
    assert true == MapType.valid?(schema, %{})
  end

  test "#errors for cases with optional fields" do
    schema =
      map(
        fields: [
          field(key: "name", type: string(allow_nil: true), optional: false),
          field(key: "age", type: integer(gteq: 18, allow_nil: true), optional: false)
        ]
      )

    assert %{"age" => ["should exist"], "name" => ["should exist"]} = MapType.errors(schema, %{})

    assert %{
             "name" => [_error_message]
           } = MapType.errors(schema, %{"age" => nil})

    assert %{} == MapType.errors(schema, %{"age" => nil, "name" => nil})
    assert %{} == MapType.errors(schema, %{"age" => nil, "name" => "Dmitry"})
  end

  test "@errors - depends_on, fio + birthdate" do
    schema =
      map(
        fields: [
          field(
            key: "lastname",
            type: string(),
            depends_on: ["birthdate", "firstname", "middlename"]
          ),
          field(
            key: "firstname",
            type: string(),
            depends_on: ["birthdate", "lastname", "middlename"]
          ),
          field(
            key: "middlename",
            type: string(),
            depends_on: ["birthdate", "lastname", "firstname"]
          ),
          field(
            key: "birthdate",
            type: string(),
            depends_on: ["lastname", "firstname", "middlename"]
          )
        ]
      )

    assert %{
             "firstname" => ["should exist"],
             "lastname" => ["should exist"],
             "birthdate" => ["should exist"],
             "middlename" => ["should exist"]
           } = MapType.errors(schema, %{})

    assert %{
             "firstname" => ["should exist"],
             "lastname" => ["should exist"],
             "middlename" => ["should exist"],
             "birthdate" => ["all dependens_on fields should exist"]
           } == MapType.errors(schema, %{"birthdate" => "1898-06-05"})

    assert %{
             "birthdate" => ["should exist"],
             "firstname" => ["all dependens_on fields should exist"],
             "lastname" => ["all dependens_on fields should exist"],
             "middlename" => ["should exist"]
           } ==
             MapType.errors(schema, %{
               "lastname" => "Лорка",
               "firstname" => "Федерико"
             })

    assert %{"firstname" => ["nil", "should be StringType"], "lastname" => ["can not be blank"]} ==
             MapType.errors(schema, %{
               "lastname" => "",
               "firstname" => nil,
               "middlename" => "Гарсия",
               "birthdate" => "1898-06-05"
             })

    assert %{} ==
             MapType.errors(schema, %{
               "lastname" => "Лорка",
               "firstname" => "Федерико",
               "middlename" => "Гарсия",
               "birthdate" => "1898-06-05"
             })
  end

  test "@errors - depends_on, fio + birthdate with optional middlename" do
    schema =
      map(
        required_groups: ["inn", "lastname", "firstname", "birthdate"],
        fields: [
          field(
            key: "lastname",
            type: string(),
            depends_on: ["birthdate", "firstname"]
          ),
          field(
            key: "firstname",
            type: string(),
            depends_on: ["birthdate", "lastname"]
          ),
          field(
            key: "middlename",
            type: string(),
            optional: true,
            depends_on: ["birthdate", "lastname", "firstname"]
          ),
          field(
            key: "birthdate",
            type: string(),
            depends_on: ["lastname", "firstname"]
          ),
          field(key: "inn", type: string())
        ]
      )

    assert ["one of keys should exist"] = MapType.errors(schema, %{})
    assert %{} == MapType.errors(schema, %{"inn" => "3015081111"})

    assert %{
             "birthdate" => ["all dependens_on fields should exist"]
           } == MapType.errors(schema, %{"birthdate" => "1898-06-05"})

    assert %{
             "firstname" => ["all dependens_on fields should exist"],
             "lastname" => ["all dependens_on fields should exist"]
           } ==
             MapType.errors(schema, %{
               "inn" => "3015081111",
               "lastname" => "Лорка",
               "firstname" => "Федерико"
             })

    assert %{
             "firstname" => ["all dependens_on fields should exist"],
             "lastname" => ["all dependens_on fields should exist"]
           } ==
             MapType.errors(schema, %{
               "lastname" => "Лорка",
               "firstname" => "Федерико"
             })

    assert %{"firstname" => ["nil", "should be StringType"], "lastname" => ["can not be blank"]} ==
             MapType.errors(schema, %{
               "lastname" => "",
               "firstname" => nil,
               "middlename" => "Гарсия",
               "birthdate" => "1898-06-05"
             })

    assert %{} ==
             MapType.errors(schema, %{
               "lastname" => "Лорка",
               "firstname" => "Федерико",
               "middlename" => "Гарсия",
               "birthdate" => "1898-06-05"
             })

    assert %{} ==
             MapType.errors(schema, %{
               "lastname" => "Лорка",
               "firstname" => "Федерико",
               "birthdate" => "1898-06-05"
             })
  end

  test "#errors - with required one of many fields" do
    schema =
      map(
        required_any_one: true,
        fields: [
          field(key: "name", type: string()),
          field(key: "age", type: integer(gteq: 18))
        ]
      )

    assert ["one of keys should exist"] = MapType.errors(schema, %{})

    assert %{
             "name" => _error_message
           } = MapType.errors(schema, %{"age" => nil})

    assert %{
             "name" => ["nil", "should be StringType"],
             "age" => ["nil", "should be integer type"]
           } ==
             MapType.errors(schema, %{"age" => nil, "name" => nil})

    assert %{
             "name" => ["nil", "should be StringType"],
             "age" => ["should exist"]
           } == MapType.errors(schema, %{"name" => nil})

    assert %{"name" => ["nil", "should be StringType"]} ==
             MapType.errors(schema, %{"name" => nil, "age" => 21})

    assert %{} == MapType.errors(schema, %{"age" => 18, "name" => "Dmitry"})
    assert %{} == MapType.errors(schema, %{"name" => "Dmitry"})
    assert %{} == MapType.errors(schema, %{"age" => 88})
  end
end

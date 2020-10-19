defmodule TalosTest do
  use ExUnit.Case
  doctest Talos

  alias Talos.Types.MapType
  alias Talos.Types.MapType.Field
  alias Talos.Types.ListType
  alias Talos.Types.EnumType
  alias Talos.Types.NumberType
  alias Talos.Types.StringType
  import Talos

  @interests_type %EnumType{
    members: [
      "sports",
      "games",
      "food"
    ]
  }

  @user_type %MapType{
    fields: [
      %Field{key: "email", type: %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
      %Field{key: "age", type: %NumberType{gteq: 18, allow_nil: true}},
      %Field{key: "interests", type: %ListType{type: @interests_type, allow_nil: true}}
    ]
  }

  @request_type %MapType{
    fields: [
      %Field{key: "action", type: %EnumType{members: ["create_users", "notify_users"]}},
      %Field{key: "users", type: %ListType{type: @user_type}}
    ]
  }

  test "Integration test with hard struct" do
    data = %{
      "action" => "notify_users",
      "users" => [
        %{"email" => "user1@example.ru", "age" => nil, "interests" => nil},
        %{"email" => "user2@example.ru", "age" => 18, "interests" => ["food"]},
        %{"email" => "user3@example.ru", "age" => 23, "interests" => ["food", "games"]}
      ]
    }

    assert true == Talos.valid?(@request_type, data)
    assert %{} == Talos.errors(@request_type, data)

    assert %{
             "action" => [_error_message],
             "users" => [_errors_message]
           } = Talos.errors(@request_type, %{})
  end

  describe "DSL tests" do
    import Talos

    test "Module" do
      defmodule Foo do
        import Talos

        @list list(max_length: 2)

        def check(data) do
          Talos.valid?(@list, data)
        end
      end

      assert Foo.check([]) == true
      assert Foo.check([1]) == true
      assert Foo.check([1, 2]) == true
      assert Foo.check([1, 2, 3]) == false
      assert Foo.check(nil) == false
    end

    test "MapType" do
      assert %MapType{allow_blank: false, allow_nil: false, fields: []} = map(fields: [])
      assert %MapType{allow_blank: false, allow_nil: false, fields: nil} = map()

      assert %MapType{allow_blank: true, allow_nil: true, fields: nil} =
               map(allow_nil: true, allow_blank: true)

      assert %MapType{allow_blank: true, allow_nil: true, fields: nil} =
               map(allow_nil: true, allow_blank: true)

      # With Feilds
      assert %MapType{
               allow_blank: false,
               allow_nil: false,
               fields: [%Field{key: "some_key", optional: false, type: %StringType{}}]
             } =
               map(
                 fields: [
                   field(key: "some_key", type: string())
                 ]
               )
    end

    test "StringType" do
      assert %StringType{} = string()
      assert %StringType{max_length: 3} = string(max_length: 3)
    end

    test "Nested" do
      user =
        map(
          fields: [
            field(
              key: "email",
              type: string(min_length: 5, max_length: 255, regexp: ~r/.*@.*/)
            ),
            field(key: "age", type: number(gteq: 18, allow_nil: true)),
            field(
              key: "interests",
              type:
                list(
                  allow_nil: true,
                  type: enum(members: ["sports", "games", "food"])
                )
            )
          ]
        )

      dsl_schema =
        map(
          fields: [
            field(key: "action", type: enum(members: ["create_users", "notify_users"])),
            field(
              key: "users",
              type: list(type: user)
            )
          ]
        )

      assert dsl_schema == @request_type
    end
  end

  describe "Permit structs" do
    test "#permit" do
      element =
        map(
          allow_nil: true,
          fields: [
            field(key: "name", type: string()),
            field(key: "loved_digits", type: list(), optional: true)
          ]
        )

      schema =
        map(
          fields: [
            field(key: "action", type: string()),
            field(key: "list", type: list(type: element)),
            field(key: "list_allows_nil", type: list(type: element))
          ]
        )

      assert %{
               "action" => "choose_girlfriend",
               "list" => [%{"name" => "Janna"}, %{"name" => "Eliza"}],
               "list_allows_nil" => [nil, %{"name" => "Oscar", "loved_digits" => [1, 2, 3, 4, 5]}]
             } =
               result =
               Talos.permit(schema, %{
                 "action" => "choose_girlfriend",
                 "target" => "Some Lonely man",
                 "list" => [
                   %{"name" => "Janna", "age" => 13},
                   %{"name" => "Eliza", "has_rich_daddy" => true}
                 ],
                 "list_allows_nil" => [
                   nil,
                   %{"name" => "Oscar", "loved_digits" => [1, 2, 3, 4, 5]}
                 ]
               })

      assert Talos.errors(schema, result) == %{}
      assert Talos.valid?(schema, result) == true
    end
  end
end

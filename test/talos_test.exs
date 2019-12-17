defmodule TalosTest do
  use ExUnit.Case
  doctest Talos

  alias Talos.Types.MapType
  alias Talos.Types.ListType
  alias Talos.Types.EnumType
  alias Talos.Types.NumberType
  alias Talos.Types.StringType

  @interests_type %EnumType{
    members: [
      "sports",
      "games",
      "food"
    ]
  }

  @user_type %MapType{
    fields: [
      {"email", %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
      {"age", %NumberType{gteq: 18, allow_nil: true}},
      {"interests", %ListType{type: @interests_type, allow_nil: true}}
    ]
  }

  @request_type %MapType{
    fields: [
      {"action", %EnumType{members: ["create_users", "notify_users"]}, optional: false},
      {"users", %ListType{type: @user_type}}
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
end

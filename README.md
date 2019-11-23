# Talos

Talos is simple parameters validation library

Documentation can be found at [ExDoc](https://hexdocs.pm/talos/)

## Sample example

```elixir
defmodule MyAppWeb.UserController do
  # we define required types
  alias Talos.Types.MapType
  alias Talos.Types.ArrayType
  alias Talos.Types.EnumType
  alias Talos.Types.NumberType
  alias Talos.Types.StringType
  # here we define expected struct
  @interests_type %EnumType{
    members: [
      "sports",
      "games",
      "food"
    ]
  }
  # one struct can be nested in another
  @user_type %MapType{
    fields: [
      {"email", %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
      {"age", %NumberType{gteq: 18}, allow_nil: true},
      {"interests", %ArrayType{type: @interests_type}, allow_nil: true}
    ]
  }
  def create(conn, params) do
    case Talos.valid?(@user_type, params) do
      true ->
        user = MyApp.create_user(params)
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))
      false ->
        conn
        |> put_flash(:info, "Wrong params passed.")
        |> render("new.html")
    end
  end
end
```

## Installation

```elixir
def deps do
  [
    {:talos, "~> 0.3.2"}
  ]
end
```

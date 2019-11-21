defmodule Talos do
  @moduledoc """
  Documentation for Talos.

  Talos is params type validation library, can be used with Phoenix or another Framework

  Sample usage:

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
  """

  @spec valid?(%{__struct__: atom}, any) :: boolean
  def valid?(%{__struct__: type_module} = data_type, data) do
    type_module.valid?(data_type, data)
  end

  @spec errors(%{__struct__: atom}, any) :: any
  def errors(%{__struct__: type_module} = data_type, data) do
    type_module.errors(data_type, data)
  end
end

defmodule Talos do
  alias Talos.Types.MapType
  alias Talos.Types.MapType.Field
  alias Talos.Types.ListType

  @moduledoc """
  Documentation for Talos.

  Talos is params type validation library, can be used with any Elixir application

  Sample usage:

  ```elixir
  defmodule MyAppWeb.UserController do
    # just import talos with functions helpers
    import Talos

    @interests_type enum(members: ["sports", "games", "food"]) # <- subtype
    # here we define expected struct 
    @user_type map(fields: [
      field(key: "email", type: string(min_length: 5, max_length: 255, regexp: ~r/.*@.*/)),
      field(key: "age", type: integer(gteq: 18, allow_nil: true)),
      field(key: "interests", type: list(type: @interests_type), optional: true)
    ])

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

  @spec valid?(struct | module, any) :: boolean
  def valid?(%{__struct__: type_module} = data_type, data) do
    type_module.valid?(data_type, data)
  end

  def valid?(module, value) do
    module.valid?(module, value)
  end

  @spec permit(struct | module, any) :: boolean
  def permit(%{__struct__: type_module} = data_type, data) do
    case type_module do
      MapType -> MapType.permit(data_type, data)
      ListType -> ListType.permit(data_type, data)
      _another -> data
    end
  end

  def permit(_module, value) do
    value
  end

  @spec errors(struct | module, any) :: any
  def errors(%{__struct__: type_module} = data_type, data) do
    type_module.errors(data_type, data)
  end

  def errors(module, value) do
    module.errors(module, value)
  end

  def map(args \\ []) do
    talos_build_struct(%MapType{}, args)
  end

  def field(args \\ []) do
    talos_build_struct(
      %Field{
        key: Keyword.get(args, :key),
        type: Keyword.get(args, :key)
      },
      args
    )
  end

  # Functions Helpers

  def enum(args \\ []) do
    talos_build_struct(%Talos.Types.EnumType{}, args)
  end

  def boolean(args \\ []) do
    talos_build_struct(%Talos.Types.BooleanType{}, args)
  end

  def fixed(args \\ []) do
    talos_build_struct(%Talos.Types.FixedType{}, args)
  end

  def float(args \\ []) do
    talos_build_struct(%Talos.Types.FloatType{}, args)
  end

  def integer(args \\ []) do
    talos_build_struct(%Talos.Types.IntegerType{}, args)
  end

  def list(args \\ []) do
    talos_build_struct(%Talos.Types.ListType{}, args)
  end

  def number(args \\ []) do
    talos_build_struct(%Talos.Types.NumberType{}, args)
  end

  def string(args \\ []) do
    talos_build_struct(%Talos.Types.StringType{}, args)
  end

  defp talos_build_struct(type, args) do
    keys = Map.keys(type)

    Enum.reduce(keys, type, fn key, res ->
      Map.put(res, key, Keyword.get(args, key) || Map.get(type, key))
    end)
  end
end

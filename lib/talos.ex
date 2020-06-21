defmodule Talos do
  @moduledoc """
  Documentation for Talos.

  Talos is params type validation library, can be used with Phoenix or another Framework

  Sample usage:

  ```elixir
  defmodule MyAppWeb.UserController do
    # we define required types and structs
    alias Talos.Field
    alias Talos.Types.MapType
    alias Talos.Types.ListType
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
        %Field{key: "email" type: %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
        %Field{key: "age" type: %NumberType{gteq: 18}, allow_nil: true},
        %Field{key: "interests" type: %ListType{type: @interests_type}, allow_nil: true}
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

  @spec valid?(struct | module, any) :: boolean
  def valid?(%{__struct__: type_module} = data_type, data) do
    type_module.valid?(data_type, data)
  end

  def valid?(module, value) do
    module.valid?(module, value)
  end

  @spec errors(struct | module, any) :: any
  def errors(%{__struct__: type_module} = data_type, data) do
    type_module.errors(data_type, data)
  end

  def errors(module, value) do
    module.errors(module, value)
  end

  defmacro __using__(_any) do
    quote do
      def map(args \\ []) do
        talos_build_struct(%Talos.Types.MapType{}, args)
      end

      def field(args \\ []) do
        talos_build_struct(
          %Talos.Types.MapType.Field{
            key: Keyword.get(args, :key),
            type: Keyword.get(args, :key)
          },
          args
        )
      end

      def enum(args \\ []) do
        talos_build_struct(%Talos.Types.EnumType{}, args)
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
  end
end

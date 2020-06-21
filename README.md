# Talos

[![Coverage Status](https://coveralls.io/repos/github/CatTheMagician/talos/badge.svg)](https://coveralls.io/github/CatTheMagician/talos)
![build](https://github.com/CatTheMagician/talos/workflows/Elixir%20CI/badge.svg)

Talos is simple parameters validation library

Documentation can be found at [ExDoc](https://hexdocs.pm/talos/)

## Why another one validation library?

I needed more checks than just whether the value belonged to one or another type. And I do not like the existing solutions with DSL, which significantly change the language

## Usage

```elixir
  defmodule CheckUserJSON do
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
        %Field{key: "email", type: %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
        %Field{key: "age", type: %NumberType{gteq: 18, allow_nil: true}},
        %Field{key: "interests", type: %ListType{type: @interests_type}, optional: true}
      ]
    }

    def validate(map_data) do
      errors = Talos.errors(@user_type, map_data)

      case errors == %{} do
        true -> :ok
        false -> {:error, errors}
      end
    end
  end
```

Somewhere in UserController
```elixir

  ...

  def new_user(conn, params)
    case CheckUserJSON.valid?(params) do
       :ok -> 
          result = MyApp.register_user!(params)
          render_json(%{"ok" => true)
       {:error, errors} -> 
          render_json_errors(errors)
    end
  end
  
  ...
```

## Own Type definition

If you want define own Type, just create module with `Talos.Types` behavior

```elixir
defmodule ZipCodeType do
  @behaviour Talos.Types

  def valid?(__MODULE__, value) do
    String.valid?(value) && String.match?(value, ~r/\d{6}/)
  end

  def errors(__MODULE__, value) do
    case valid?(__MODULE__,value) do
      true -> []
      false -> ["#{value} is not zipcode"]
    end
  end
end

# And use it

Talos.valid?(ZipCodeType, "123456") # => true
Talos.valid?(ZipCodeType, "1234") # => false
Talos.valid?(ZipCodeType, 123456) # => false
```

## Installation

```elixir
def deps do
  [
    {:talos, "~> 1.6"}
  ]
end
```

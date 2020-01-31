# Talos

[![Coverage Status](https://coveralls.io/repos/github/SofaKing18/talos/badge.svg)](https://coveralls.io/github/SofaKing18/talos)

Talos is simple parameters validation library

Documentation can be found at [ExDoc](https://hexdocs.pm/talos/)

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

    def valid?(map_data) do
      errors = Talos.errors(@user_type, map_data)

      case errors == %{} do
        true -> {:ok, %{}}
        false -> {:nok, errors}
      end
    end
  end

  CheckUserJSON.valid?(%{}) 
  # => {:nok, %{"age" => ["should exist"], "email" => ["should exist"]}}

  CheckUserJSON.valid?(%{"age" => 13, "email" => "sofakingworld@gmail.com"})
  # => {:nok, %{"age" => ["13 does not match type Talos.Types.NumberType"}}

  CheckUserJSON.valid?(%{"age" => 23, "email" => "sofakingworld@gmail.com"})
  # => {:ok, %{}}
```

## Own Type definition

If you want define own Type, just create module with Talos.Types behavior

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
    {:talos, "~> 1.0"}
  ]
end
```

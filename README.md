# Talos

[![hex.pm](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/talos)
[![hex.pm](https://img.shields.io/hexpm/v/talos.svg)](https://hex.pm/packages/talos)
[![hex.pm](https://img.shields.io/hexpm/dt/talos.svg)](https://hex.pm/packages/talos)
[![hex.pm](https://img.shields.io/hexpm/l/talos.svg)](https://hex.pm/packages/talos)
[![github.com](https://img.shields.io/github/last-commit/balance-platform/talos.svg)](https://github.com/balance-platform/talos/commits/master)
![Elixir CI](https://github.com/balance-platform/talos/workflows/Elixir%20CI/badge.svg)

Talos is simple parameters validation library

Documentation can be found at [ExDoc](https://hexdocs.pm/talos/)

## Why another one validation library?

I needed more checks than just whether the value belonged to a particular data type. 

This library allows you to define your own checks and use typical checks with a simple setup.

## Flow

![](/.github/images/main_steps.png)

## Usage

```elixir
  defmodule CheckUserJSON do
    import Talos

    @interests_type enum(members: ["sports", "games", "food"])
    @user map(fields: [
      field(key: "email", type: string(min_length: 5, max_length: 255, regexp: ~r/.*@.*/)),
      field(key: "age", type: integer(gteq: 18, allow_nil: true)),
      field(key: "interests", type: list(type: @interests_type), optional: true)
    ])

    def validate(%{} = map_data) do
      errors = Talos.errors(@user, map_data)

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
  defstruct [length: 6]

  def valid?(%__MODULE__{length: len}, value) do
    String.valid?(value) && String.match?(value, ~r/\d{len}/)
  end

  def errors(__MODULE__, value) do
    case valid?(__MODULE__,value) do
      true -> []
      false -> ["#{value} is not zipcode"]
    end
  end
end

# And use it

Talos.valid?(%ZipCodeType{}, "123456") # => true
Talos.valid?(%ZipCodeType{}, "1234") # => false
Talos.valid?(%ZipCodeType{}, 123456) # => false
```

## Installation

```elixir
def deps do
  [
    {:talos, "~> 1.11"}
  ]
end
```

# Contribution

Feel free to make a pull request. All contributions are appreciated!

defmodule Talos.Types.MapType do
  @moduledoc """
  MapType for validation maps

  Fields are tuples `{key, type, options \\ []}`:

    `key` - string or atom, key of map
    
    `type` - Talos defined Type
    
    `options`: 
    
      * `optional`: true/false, if false - there will be error on key missing

  For example:
  ```elixir

    iex> import Talos
    iex> Talos.valid?(map(), %{foo: :bar})
    true
    iex> user_params = map(fields: [
    ...>  field(key: "email", type: string(min_length: 5, max_length: 255, regexp: ~r/.*@.*/)),
    ...>  field(key: "age", type: integer(gteq: 18, allow_nil: true)),
    ...>  field(key: "interests", type: list(type: string()), optional: true)
    ...> ])
    iex> Talos.valid?(user_params, %{})
    false
    iex> Talos.valid?(user_params, %{"email" => "bob@gmail.com", "age" => 30})
    true
    iex> Talos.valid?(user_params, %{"email" => "bob@gmail.com", "age" => 30, interests: ["elixir"]})
    true
  """

  defstruct [:fields, allow_nil: false, allow_blank: false]

  @behaviour Talos.Types

  alias Talos.Types.MapType.Field
  alias Talos.Field, as: DeprecatedField

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          allow_blank: boolean,
          fields: list(Field.t()) | nil
        }

  @spec valid?(Talos.Types.MapType.t(), any) :: boolean
  def valid?(%__MODULE__{} = module, value) do
    errors(module, value) == %{}
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    %{}
  end

  def errors(%__MODULE__{fields: fields, allow_blank: allow_blank}, map) do
    if is_map(map) && Map.keys(map) == [] && allow_blank do
      %{}
    else
      case is_map(map) do
        false ->
          [inspect(map), "should be MapType"]

        true ->
          (fields || [])
          |> Enum.map(fn field -> field_errors(field, map) end)
          |> Enum.reject(fn {_key, errors} -> errors == [] || errors == %{} end)
          |> Map.new()
      end
    end
  end

  defp field_errors(%Field{} = field, map) do
    Talos.errors(field, map)
  end
  defp field_errors(%DeprecatedField{} = field, map) do
    Talos.errors(field, map)
  end
end

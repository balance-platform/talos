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

    iex> alias Talos.Types.MapType
    iex> alias Talos.Types.MapType.Field
    iex> alias Talos.Types.StringType
    iex> alias Talos.Types.ListType
    iex> alias Talos.Types.IntegerType
    iex> any_map = %MapType{}
    iex> Talos.valid?(any_map, %{foo: :bar})
    true
    iex> user_params = %MapType{fields: [
    ...>  %Field{key: "email", type: %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
    ...>  %Field{key: "age", type: %IntegerType{gteq: 18, allow_nil: true}},
    ...>  %Field{key: "interests", type: %ListType{type: %StringType{}}, optional: true}
    ...> ]}
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

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          allow_blank: boolean,
          fields: list(Talos.Field.t()) | nil
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
          |> Enum.map(fn %Field{} = field ->
            Talos.errors(field, map)
          end)
          |> Enum.reject(fn {_key, errors} -> errors == [] || errors == %{} end)
          |> Map.new()
      end
    end
  end
end

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
    iex> alias Talos.Types.StringType
    iex> alias Talos.Types.ListType
    iex> alias Talos.Types.IntegerType
    iex> alias Talos.Field
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

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          allow_blank: boolean,
          fields: list(Talos.Field.t()) | nil
        }

  @spec valid?(Talos.Types.MapType.t(), any) :: boolean
  def valid?(%__MODULE__{allow_blank: true}, %{}) do
    true
  end

  def valid?(%__MODULE__{allow_nil: true}, nil) do
    true
  end

  def valid?(%__MODULE__{fields: nil}, value) do
    is_map(value)
  end

  def valid?(%__MODULE__{fields: fields}, value) do
    is_map(value) &&
      Enum.all?(fields, fn %Talos.Field{} = field ->
        Talos.valid?(field, value)
      end)
  end

  @spec errors(Talos.Types.MapType.t(), binary) :: list(String.t()) | map
  def errors(%__MODULE__{fields: fields} = type, value) do
    cond do
      is_nil(fields) && is_map(value) ->
        %{}

      !is_map(value) ->
        ["#{inspect(value)} does not match #{inspect(type)}"]

      !valid?(type, value) ->
        errors_for_fields(fields, value)

      true ->
        %{}
    end
  end

  defp errors_for_fields(fields, map) do
    Enum.map(fields, fn %Talos.Field{} = field ->
      Talos.errors(field, map)
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end
end

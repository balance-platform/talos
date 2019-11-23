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
    iex> alias Talos.Types.ArrayType
    iex> alias Talos.Types.IntegerType
    iex> any_map = %MapType{}
    iex> Talos.valid?(any_map, %{foo: :bar})
    true
    iex> user_params = %MapType{fields: [
    ...>  {"email", %StringType{min_length: 5, max_length: 255, regexp: ~r/.*@.*/}},
    ...>  {"age", %IntegerType{gteq: 18, allow_nil: true}},
    ...>  {"interests", %ArrayType{type: %StringType{}}, optional: true}
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
  @default_options %{optional: false}

  @type field :: {any, struct | module, keyword}
  @type short_field :: {any, struct | module}
  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          allow_blank: boolean,
          fields: list(field | short_field) |nil
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
      Enum.all?(fields, fn field ->
        case field do
          {key, type} ->
            validation_check(type, value, key)

          {key, type, options} ->
            validation_check(type, value, key, options)
        end
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
    fields
    |> Enum.map(fn field ->
      case field do
        {key, type} ->
          case validation_check(type, map, key) do
            true -> nil
            false -> {key, Talos.errors(type, map[key])}
          end

        {key, type, options} ->
          case validation_check(type, map, key, options) do
            true -> nil
            false -> {key, Talos.errors(type, map[key])}
          end
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end

  defp validation_check(type, map, key, opts \\ %{}) do
    options = Map.merge(@default_options, Map.new(opts))

    cond do
      options[:optional] && !Map.has_key?(map, key) -> true
      !options[:optional] && !Map.has_key?(map, key) -> false
      is_nil(type) -> true
      true -> Talos.valid?(type, map[key])
    end
  end
end

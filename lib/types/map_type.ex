defmodule Talos.Types.MapType do
  @moduledoc """
  MapType for validation maps

  `custom options`:

      * `required_any_one`: true/false, if true - validation check if map has any valid field
      * `required_groups`: list("key1", "key2", ...), list of keys from required group,
       required group can be simple field or field with dependendencies,
       you need to specify all field from the group to check dependencies

  Fields are tuples `{key, type, options \\ []}`:

    `key` - string or atom, key of map

    `type` - Talos defined Type

    `options`:

      * `optional`: true/false, if false - there will be error on key missing
      * `depends_on`: list("key1", "key2", ...), list of keys on which field depends,
        field pass validation only if this field and all dependent fields pass validation

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
    iex> deps = map(fields: [
    ...>  field(
    ...>   key: "lastname",
    ...>   type: string(),
    ...>   depends_on: ["birthdate", "firstname"]
    ...>  ),
    ...>  field(
    ...>   key: "firstname",
    ...>   type: string(),
    ...>   depends_on: ["birthdate", "lastname"]
    ...>  ),
    ...>  field(
    ...>   key: "birthdate",
    ...>   type: string(),
    ...>   depends_on: ["lastname", "firstname"]
    ...>  )
    ...>  ])
    iex> Talos.valid?(deps, %{})
    false
    iex> Talos.valid?(deps, %{"firstname" => "John", "lastname" => "Galt"})
    false
    iex> Talos.valid?(deps, %{"firstname" => "John", "lastname" => "Galt", "birthdate" => "1957-01-01"})
    true
  """

  defstruct [
    :fields,
    allow_nil: false,
    allow_blank: false,
    required_any_one: false,
    required_groups: nil
  ]

  @behaviour Talos.Types

  alias Talos.Types.MapType.Field

  @type t :: %{
          __struct__: atom,
          allow_nil: boolean,
          allow_blank: boolean,
          required_any_one: boolean(),
          required_groups: list(),
          fields: list(Field.t()) | nil
        }

  @spec valid?(Talos.Types.MapType.t(), any) :: boolean
  def valid?(%__MODULE__{} = module, value) do
    errors(module, value) == %{}
  end

  def errors(%__MODULE__{allow_nil: true}, nil) do
    %{}
  end

  def errors(%__MODULE__{fields: _fields}, map) when not is_map(map) do
    [inspect(map), "should be MapType"]
  end

  def errors(
        %__MODULE__{
          fields: fields,
          allow_blank: allow_blank,
          required_any_one: any_one,
          required_groups: groups
        },
        map
      ) do
    keys = Map.keys(map)

    cond do
      Enum.empty?(keys) && allow_blank ->
        %{}

      any_one == true && Enum.empty?(keys) ->
        ["one of keys should exist"]

      any_one == true && has_values(map) ->
        keys
        |> fields_by_key(fields)
        |> find_field_errors(map)

      is_list(groups) && Enum.empty?(groups) ->
        ["list should have value"]

      is_list(groups) && !Enum.empty?(groups) && !Enum.empty?(keys) ->
        groups
        |> Enum.filter(fn key -> Enum.member?(keys, key) end)
        |> fields_by_key(fields)
        |> find_field_errors(map)

      true ->
        (fields || [])
        |> find_field_errors(map)
    end
  end

  defp fields_by_key(keys, fields) do
    Enum.map(keys, fn key -> Enum.find(fields, &(&1.key == key)) end)
  end

  defp find_field_errors(fields, map) do
    fields
    |> Enum.map(fn field -> field_errors(field, map) end)
    |> Enum.reject(fn {_key, errors} -> errors == [] || errors == %{} end)
    |> Map.new()
  end

  defp has_values(map) do
    if map == %{} do
      false
    else
      Enum.all?(map, fn {_k, value} -> !is_nil(value) end)
    end
  end

  @spec permit(Talos.Types.MapType.t(), any) :: any
  def permit(%__MODULE__{fields: fields, allow_nil: allow_nil, allow_blank: allow_blank}, value) do
    cond do
      allow_blank && is_map(value) && Map.keys(value) == [] ->
        value

      allow_nil && is_nil(value) ->
        value

      is_nil(fields) ->
        value

      Enum.empty?(fields) ->
        value

      is_map(value) ->
        map = value

        Enum.reduce(fields, %{}, fn %Field{key: key, type: type}, acc ->
          if Map.has_key?(value, key) do
            Map.put(acc, key, Talos.permit(type, map[key]))
          else
            acc
          end
        end)

      true ->
        value
    end
  end

  defp field_errors(%Field{} = field, map) do
    Talos.errors(field, map)
  end
end

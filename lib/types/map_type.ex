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

  def errors(%__MODULE__{fields: fields, required_any_one: true, required_groups: nil}, map) do
    has_values = Enum.all?(map, fn {_k, value} -> !is_nil(value) end)

    cond do
      Enum.empty?(Map.keys(map)) ->
        ["one of keys should exist"]

      has_values ->
        %{}

      true ->
        (fields || [])
        |> Enum.map(fn field -> field_errors(field, map) end)
        |> Enum.reject(fn {_key, errors} -> errors == [] || errors == %{} end)
        |> Map.new()
    end
  end

  def errors(%__MODULE__{fields: fields, required_groups: list, allow_blank: false}, map) when is_list(list) do
    keys = Map.keys(map)

    if Enum.empty?(keys) do
        ["one of keys should exist"]
    else
        # проверить поля из required_groups
        list
        |> Enum.filter(fn key -> Enum.member?(keys, key) end)
        |> Enum.map(fn key -> Enum.find(fields, &(&1.key == key)) end)
        |> Enum.map(fn field -> field_errors(field, map) end)
        |> Enum.reject(fn {_key, errors} -> errors == [] || errors == %{} end)
        |> Map.new()
    end
  end

  def errors(%__MODULE__{fields: fields, allow_blank: allow_blank, required_groups: nil}, map) do
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
          case Map.has_key?(value, key) do
            true ->
              Map.put(acc, key, Talos.permit(type, map[key]))

            false ->
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

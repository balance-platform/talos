defmodule Talos.Helpers.SchemaToMap do
  @moduledoc """
  Schema to map, might be usefull for building documentation page
  """

  alias Talos.Types.MapType.Field
  alias Talos.Types.MapType
  alias Talos.Types.EnumType
  alias Talos.Types.ListType

  def convert(%MapType{} = schema) do
    fields = Enum.map(schema.fields || [], &convert/1)

    struct_to_map(%MapType{schema | fields: fields})
  end

  def convert(%EnumType{} = enum) do
    members = Enum.map(enum.members, &convert/1)

    struct_to_map(%EnumType{enum | members: members})
  end

  def convert(%ListType{} = list) do
    type = convert(list.type)

    struct_to_map(%ListType{list | type: type})
  end

  def convert(%Field{} = field) do
    %{
      key: field.key,
      description: field.description,
      optional: field.optional,
      default_value: field.default_value,
      type_name: inspect(field.type.__struct__),
      type: convert(field.type)
    }
  end

  def convert(other) when is_map(other) do
    case is_nil(other.__struct__) do
      true -> other
      false -> struct_to_map(other)
    end
  end

  def convert(other) do
    other
  end

  defp struct_to_map(struct) do
    keys = Map.keys(struct)

    tuples =
      Enum.map(keys, fn key ->
        value = Map.get(struct, key)

        cond do
          :__struct__ == key -> {:type_name, inspect(value)}
          :regexp == key && !is_nil(value) -> {key, inspect(value)}
          true -> {key, value}
        end
      end)

    map = Map.new(tuples)

    Map.put(map, :type_name, struct.__struct__)
  end
end

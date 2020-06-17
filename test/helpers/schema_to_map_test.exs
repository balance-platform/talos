defmodule Talos.Helpers.SchemaToMapTest do
  use ExUnit.Case

  alias Talos.Helpers.SchemaToMap

  alias Talos.Types.MapType
  alias Talos.Field
  alias Talos.Types.FixedType
  alias Talos.Types.StringType
  alias Talos.Types.IntegerType
  alias Talos.Types.EnumType
  alias Talos.Types.ListType

  @long_schema %MapType{
    fields: [
      %Field{
        key: "id",
        type: %EnumType{members: [%StringType{}, %IntegerType{}], example_value: "ID-123456"},
        description: "some id"
      },
      %Field{
        key: "user_uid",
        type: %StringType{example_value: "d.shpagin"},
        description: "user uid",
        optional: true
      },
      %Field{
        key: "params",
        type: %MapType{
          fields: [
            %Field{
              key: "action",
              type: %FixedType{value: "transfer_money"},
              description: "action name"
            },
            %Field{
              key: "action_params",
              description: "action params",
              type: %MapType{
                fields: [
                  %Field{
                    key: "cards",
                    type: %ListType{type: %IntegerType{}}
                  }
                ]
              }
            }
          ]
        }
      }
    ]
  }

  test "#returns expected info" do
    assert %{
             allow_blank: false,
             allow_nil: false,
             fields: [
               %{
                 default_value: nil,
                 description: "some id",
                 key: "id",
                 optional: false,
                 type_name: "Talos.Types.EnumType",
                 type: %{
                   allow_nil: false,
                   example_value: "ID-123456",
                   members: [
                     %{
                       allow_blank: false,
                       allow_nil: false,
                       example_value: nil,
                       length: nil,
                       max_length: nil,
                       min_length: nil,
                       regexp: nil,
                       type_name: Talos.Types.StringType
                     },
                     %{
                       allow_blank: false,
                       allow_nil: false,
                       example_value: nil,
                       gt: nil,
                       gteq: nil,
                       lt: nil,
                       lteq: nil,
                       type_name: Talos.Types.IntegerType
                     }
                   ],
                   type_name: Talos.Types.EnumType
                 }
               },
               %{
                 default_value: nil,
                 description: "user uid",
                 key: "user_uid",
                 optional: true,
                 type_name: "Talos.Types.StringType",
                 type: %{
                   allow_blank: false,
                   allow_nil: false,
                   example_value: "d.shpagin",
                   length: nil,
                   max_length: nil,
                   min_length: nil,
                   regexp: nil,
                   type_name: Talos.Types.StringType
                 }
               },
               %{
                 default_value: nil,
                 description: nil,
                 key: "params",
                 optional: false,
                 type_name: "Talos.Types.MapType",
                 type: %{
                   allow_blank: false,
                   allow_nil: false,
                   fields: [
                     %{
                       default_value: nil,
                       description: "action name",
                       key: "action",
                       optional: false,
                       type_name: "Talos.Types.FixedType",
                       type: %{
                         allow_nil: false,
                         example_value: nil,
                         value: "transfer_money",
                         type_name: Talos.Types.FixedType
                       }
                     },
                     %{
                       default_value: nil,
                       description: "action params",
                       key: "action_params",
                       optional: false,
                       type_name: "Talos.Types.MapType",
                       type: %{
                         allow_blank: false,
                         allow_nil: false,
                         fields: [
                           %{
                             default_value: nil,
                             description: nil,
                             key: "cards",
                             optional: false,
                             type_name: "Talos.Types.ListType",
                             type: %{
                               allow_blank: false,
                               allow_nil: false,
                               min_length: nil,
                               max_length: nil,
                               example_value: nil,
                               type: %{
                                 allow_blank: false,
                                 allow_nil: false,
                                 example_value: nil,
                                 gt: nil,
                                 gteq: nil,
                                 lt: nil,
                                 lteq: nil,
                                 type_name: Talos.Types.IntegerType
                               },
                               type_name: Talos.Types.ListType
                             }
                           }
                         ],
                         type_name: Talos.Types.MapType
                       }
                     }
                   ],
                   type_name: Talos.Types.MapType
                 }
               }
             ],
             type_name: Talos.Types.MapType
           } = SchemaToMap.convert(@long_schema)
  end
end

Types::ReviewRuleType = GraphQL::ObjectType.define do
  name "ReviewRule"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :name, !types.String
end

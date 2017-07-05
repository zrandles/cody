Types::ReviewerType = GraphQL::ObjectType.define do
  name "Reviewer"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :login, types.String
  field :status, types.String
end

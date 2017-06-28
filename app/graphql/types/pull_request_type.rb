Types::PullRequestType = GraphQL::ObjectType.define do
  name "PullRequest"

  implements GraphQL::Relay::Node.interface

  global_id_field :id
  field :number, types.String
  field :repository, types.String
  field :status, types.String
end

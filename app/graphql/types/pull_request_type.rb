Types::PullRequestType = GraphQL::ObjectType.define do
  name "PullRequest"
  field :number, types.String
  field :repository, types.String
  field :status, types.String
end

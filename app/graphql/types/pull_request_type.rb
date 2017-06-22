Types::PullRequestType = GraphQL::ObjectType.define do
  name "PullRequest"
  field :number, types.String
end

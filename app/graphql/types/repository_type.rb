Types::RepositoryType = GraphQL::ObjectType.define do
  name "Repository"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :owner, types.String
  field :name, types.String

  connection :pullRequests, Types::PullRequestType.connection_type do
    argument :status, types.String
    resolve -> (repository, args, ctx) {
      status = args[:status] || "pending_review"
      PullRequest.where(repository: "#{repository.owner}/#{repository.name}").order("created_at DESC")
    }
  end
end

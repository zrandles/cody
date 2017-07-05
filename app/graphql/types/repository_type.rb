Types::RepositoryType = GraphQL::ObjectType.define do
  name "Repository"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :owner, types.String
  field :name, types.String

  connection :pullRequests, Types::PullRequestType.connection_type do
    description "This repository's Pull Requests"
    argument :status, types.String
    resolve -> (repository, args, ctx) {
      status = args[:status] || "pending_review"
      PullRequest.where(repository: "#{repository.owner}/#{repository.name}").order("created_at DESC")
    }
  end

  field :pullRequest do
    type Types::PullRequestType
    argument :number, !types.String
    description "Find a PullRequest by number"
    resolve -> (repository, args, ctx) {
      PullRequest.find_by(number: args[:number], repository: "#{repository.owner}/#{repository.name}")
    }
  end
end

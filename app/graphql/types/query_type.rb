Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root"

  field :pullRequest do
    type Types::PullRequestType
    argument :repository, !types.String
    argument :number, !types.String
    description "Find a PullRequest by number"
    resolve -> (obj, args, ctx) { PullRequest.find_by(number: args[:number]) }
  end

  field :pullRequests do
    type types[!Types::PullRequestType]
    argument :repository, !types.String
    argument :status, !Types::PullRequestStatusType
    argument :page, types.Int
    argument :perPage, types.Int
    description "Find PullRequests belonging to a given a repository"
    resolve -> (obj, args, ctx) {
      page = args[:page] || 1
      per_page = args[:perPage] || 25
      PullRequest.where(repository: args[:repository], status: args[:status])
        .page(page)
        .per(per_page)
    }
  end
end

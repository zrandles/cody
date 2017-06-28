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

  field :repository do
    type Types::RepositoryType
    description "Find a given repository by the owner and name"
    argument :owner, !types.String
    argument :name, !types.String
    resolve -> (obj, args, ctx) {
      OpenStruct.new(owner: args[:owner], name: args[:name])
    }
  end

  field :viewer do
    type Types::UserType
    description "The currently authenticated user"
    resolve -> (obj, args, ctx) {
      Current.user
    }
  end

  field :node, GraphQL::Relay::Node.field
  field :nodes, GraphQL::Relay::Node.plural_field
end

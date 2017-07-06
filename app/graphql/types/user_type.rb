Types::UserType = GraphQL::ObjectType.define do
  name "User"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :login, !types.String
  field :name, !types.String

  connection :repositories, Types::RepositoryType.connection_type do
    resolve -> (user, args, ctx) {
      PullRequest
        .distinct
        .order("repository ASC")
        .pluck(:repository)
        .map do |nwo|

        owner, name = nwo.split("/", 2)
        Repository.new(owner: owner, name: name)
      end
    }
  end

  field :repository do
    type !Types::RepositoryType
    description "Find a given repository by the owner and name"
    argument :owner, !types.String
    argument :name, !types.String
    resolve -> (obj, args, ctx) {
      OpenStruct.new(owner: args[:owner], name: args[:name])
    }
  end
end

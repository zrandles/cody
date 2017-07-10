Types::UserType = GraphQL::ObjectType.define do
  name "User"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :login, !types.String
  field :name, !types.String

  connection :repositories, Types::RepositoryType.connection_type do
    resolve -> (user, args, ctx) {
      Pundit.policy_scope(user, Repository)
    }
  end

  field :repository do
    type Types::RepositoryType
    description "Find a given repository by the owner and name"
    argument :owner, !types.String
    argument :name, !types.String
    resolve -> (user, args, ctx) {
      Pundit.policy_scope(user, Repository)
        .find do |repo|
          repo.owner == args[:owner] &&
            repo.name == args[:name]
        end
    }
  end
end

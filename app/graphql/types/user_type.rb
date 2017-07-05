Types::UserType = GraphQL::ObjectType.define do
  name "User"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :login, !types.String
  field :name, !types.String

  connection :repositories, Types::RepositoryType.connection_type do
    argument :owner, !types.String
    argument :name, !types.String

    resolve -> (user, args, ctx) {
      [Repository.new(owner: args[:owner], name: args[:name])]
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
end

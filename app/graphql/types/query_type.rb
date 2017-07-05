Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root"

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

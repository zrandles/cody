Types::ReviewerType = GraphQL::ObjectType.define do
  name "Reviewer"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :login, !types.String
  field :status, !types.String

  field :reviewRule do
    type Types::ReviewRuleType
    description "The Review Rule that added this Reviewer"
    resolve -> (reviewer, args, ctx) {
      reviewer.review_rule
    }
  end

  VersionType = GraphQL::ObjectType.define do
    name "ReviewerVersion"

    field :login, function: Functions::HashField.new(
      "login",
      types[types.String]
    )

    field :status, function: Functions::HashField.new(
      "status",
      types[types.String]
    )
  end

  field :versions do
    type types[VersionType]
    resolve -> (reviewer, args, ctx) {
      reviewer.versions.map(&:changeset)
    }
  end
end

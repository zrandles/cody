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
end

Types::PullRequestType = GraphQL::ObjectType.define do
  name "PullRequest"

  implements GraphQL::Relay::Node.interface

  global_id_field :id

  field :number, !types.String
  field :repository, !types.String
  field :status, !types.String

  connection :reviewers, Types::ReviewerType.connection_type do
    argument :status, types.String
    resolve -> (pull_request, args, ctx) {
      case args[:status]
      when Reviewer::STATUS_PENDING_APPROVAL
        pull_request.reviewers.pending_review
      when Reviewer::STATUS_APPROVED
        pull_request.reviewers.completed_review
      else
        pull_request.reviewers
      end
    }
  end
end

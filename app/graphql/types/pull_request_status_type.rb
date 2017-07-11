Types::PullRequestStatusType = GraphQL::EnumType.define do
  name "PullRequestStatus"
  description "The review status of a PullRequest"
  value("pending_review", "Pending Review")
  value("approved", "Approved")
end

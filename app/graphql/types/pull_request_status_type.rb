Types::PullRequestStatusType = GraphQL::EnumType.define do
  name "PullRequestStatus"
  description "The review status of a PullRequest"
  value("pending_approval", "Pending approval")
  value("approved", "Approved")
end

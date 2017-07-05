Types::ReviewerStatusType = GraphQL::EnumType.define do
  name "ReviewerStatus"
  description "The review status of a Reviewer"
  value("pending_approval", "Pending Approval")
  value("approved", "Approved")
end

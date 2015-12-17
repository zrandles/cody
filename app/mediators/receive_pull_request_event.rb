class ReceivePullRequestEvent
  include Sidekiq::Worker

  def perform(payload)
    reviewers = payload["pull_request"]["body"].scan(/- \[.\] @(.+)/)
    
    number = payload["number"]

    PullRequest.create!(number: number)
  end
end

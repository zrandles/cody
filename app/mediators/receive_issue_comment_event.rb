class ReceiveIssueCommentEvent
  include Sidekiq::Worker

  def perform(payload)
    return unless PullRequest.exists?(number: payload["issue"]["number"])

    pr = PullRequest.pending_review.find_by(number: payload["issue"]["number"])
    reviewers = pr.pending_reviews

    comment_author = payload["sender"]["login"]
    return unless reviewers.include?(comment_author)

    comment = payload["comment"]["body"]
    return unless comment =~ /^lgtm$/i

    reviewers.delete(comment_author)
    pr.pending_reviews = reviewers
    pr.completed_reviews << comment_author
    pr.save!

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    pull_resource = github.pull_request(ENV["CODY_GITHUB_REPO"], payload["issue"]["number"])
    pr_sha = pull_resource.head.sha

    if pr.pending_reviews.none?
      github.create_status(ENV["CODY_GITHUB_REPO"], pr_sha, "success", context: "code-review/cody", description: "Code review complete")

      pr.status = "approved"
      pr.save!
    end
  end
end

class ApplyReviewRules
  attr_reader :pr, :pull_request_hash

  def initialize(pr, pull_request_hash)
    @pr = pr
    @pull_request_hash = pull_request_hash
  end

  def perform
    # Quit if there aren't any rules for this repo
    ReviewRule.apply(pr, pull_request_hash)

    reviewers = pr.generated_reviewers
    return if reviewers.empty?

    pr.reload
    pr.update_body

    github = Octokit::Client.new(
      access_token: Rails.application.secrets.github_access_token
    )

    # Update labels
    labels = reviewers.map { |reviewer| reviewer.review_rule.name }.uniq
    github.add_labels_to_an_issue(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"],
      labels
    )
  end
end

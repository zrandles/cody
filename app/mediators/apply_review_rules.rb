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

    addendum = <<~EOF
      ## Generated Reviewers

    EOF

    reviewers.each do |reviewer|
      addendum << reviewer.addendum
    end

    # Drop existing Generated Reviewers section and replace with new one
    old_body = pull_request_hash["body"]
    prelude, _ = old_body.split(ReviewRule::GENERATED_REVIEWERS_REGEX, 2)

    new_body = prelude.rstrip + "\n\n" + addendum

    github = Octokit::Client.new(
      access_token: Rails.application.secrets.github_access_token
    )

    github.update_pull_request(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"],
      body: new_body
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

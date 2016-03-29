class ApplyReviewRules
  def perform(pull_request_hash)
    rules = ReviewRule.all

    return if rules.empty?

    added_reviewers = []

    rules.each do |rule|
      added_reviewer = rule.apply(pull_request_hash)
      if added_reviewer
        added_reviewers << [added_reviewer, rule.name]
      end
    end

    return if added_reviewers.empty?

    addendum = <<-EOF
## Generated Reviewers

EOF

    added_reviewers.each do |reviewer, rule_name|
      s = "- [ ] @#{reviewer} (#{rule_name})\n"
      addendum << s
    end

    old_body = pull_request_hash["body"]
    new_body = old_body + "\n\n" + addendum

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    github.update_pull_request(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"],
      body: new_body
    )

    labels = added_reviewers.map(&:second)
    github.add_labels_to_an_issue(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"],
      labels
    )
  end
end

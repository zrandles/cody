class ApplyReviewRules
  def perform(pull_request_hash)
    rules = ReviewRule.for_repository(pull_request_hash["base"]["repo"]["full_name"])

    return if rules.empty?

    added_reviewers = {}

    rules.each do |rule|
      result = rule.apply(pull_request_hash)
      if result.success?
        added_reviewers[rule.name] = result
      end
    end

    return if added_reviewers.empty?

    addendum = <<-EOF
## Generated Reviewers

EOF

    added_reviewers.each do |rule_name, result|
      s = <<-EOF
### #{rule_name}

- [ ] @#{result.reviewer}
#{result.context}

EOF
      addendum << s
    end

    old_body = pull_request_hash["body"]
    new_body = old_body + "\n\n" + addendum

    github = Octokit::Client.new(access_token: Rails.application.secrets.github_access_token)
    github.update_pull_request(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"],
      body: new_body
    )

    labels = added_reviewers.keys
    github.add_labels_to_an_issue(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"],
      labels
    )
  end
end

class WatcherRule < ReviewRule
  def matches?(_pull_request_hash)
    rand < frequency
  end

  # Watcher rules do not add reviewers
  def apply
    nil
  end

  # Returns the text to be appended to the PR body
  # Will contain a watchers header and @mentions
  #
  # For now this is only used for shadow reviewers, so give them a check
  # box (that will be picked up by Pickaxe but ignored by Cody)
  #
  def self.watcher_text(pr, pull_request_hash)
    watcher = single_watcher(pr, pull_request_hash)
    return "" unless watcher.present?
    <<~EOF
      ## Generated Shadow Reviewers

      - [ ] @#{watcher}

    EOF
  end

  # Returns the GitHub login name of a single watcher rule that applies
  # and was able to find a watcher.
  # If more than one watcher is chosen for this PR, pick one at random
  #
  # @param pr [PullRequest] the PullRequest object to add watcher to
  # @param pull_request_hash [Hash] the raw pull request hash
  # @return [String] the login of the watcher that was added
  def self.single_watcher(pr, pull_request_hash)
    repository = pull_request_hash["base"]["repo"]["full_name"]
    watcher_rules = WatcherRule.for_repository(repository).to_a
    watcher_rules.keep_if { |watcher_rule| watcher_rule.matches?(pull_request_hash) }.map do |watcher_rule|
      if watcher_rule.matches?(pull_request_hash)
        watcher = watcher_rule.choose_reviewer(pr)
        pr.commit_authors.include?(watcher) ? nil : watcher
      end
    end.compact.sample
  end
end

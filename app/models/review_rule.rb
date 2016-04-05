class ReviewRule < ActiveRecord::Base
  validates :name, presence: true
  validates :reviewer, presence: true

  # Apply this rule to the given Pull Request
  #
  # Returns a ReviewRuleResult possibly containing the name of the reviewer
  # and any additional context from the match.
  def apply(pull_request_hash)
    match_context = matches?(pull_request_hash)
    if match_context
      added_reviewer = add_reviewer(PullRequest.find_by(number: pull_request_hash["number"]))
      ReviewRuleResult.new(added_reviewer, match_context)
    else
      ReviewRuleResult.new(nil, nil)
    end
  end

  # Determine if this rule matches the received Pull Request
  #
  # The #matches? method should generate a string of additional context that
  # will be appended to the Generated Reviewers addendum directly below the
  # name of the reviewer that was added. This should be a Markdown-formatted
  # String. Also note that the addendum is also formatted as Markdown. This
  # means that if you want to have a blank line between the reviewer's name and
  # the start of the context, your context should begin with a newline. By
  # default there is no blank line in order to enable the creation of nested
  # lists underneath the reviewer.
  #
  # pull_request_hash - Hash-like resource from the GitHub API
  #
  # Returns truthy on a successful match; falsey otherwise. Truthy returns are
  # Strings providing extra context about the successful match.
  def matches?(*)
    # by default nothing matches
    nil
  end

  # Add the reviewer according to the rule's configuration
  #
  # pull_request - The PullRequest object to add a reviewer to
  #
  # Returns the login of the reviewer that was added
  def add_reviewer(pull_request)
    reviewers_for_picking = possible_reviewers

    reviewer_to_add = reviewers_for_picking.shuffle.detect { |r| !pull_request.pending_reviews.include?(r) }
    if reviewer_to_add.nil?
      # If we failed to choose a reviewer, that means that all of the possible
      # reviewers were already on the list. However since this rule did match
      # we should still add someone, even if they are a duplicate.
      reviewer_to_add = reviewers_for_picking.first
    end

    pull_request.pending_reviews << reviewer_to_add
    pull_request.save
    reviewer_to_add
  end

  # List the possible reviewers according to this rule's configuration
  #
  # Returns the Array listing all the possible reviewers
  def possible_reviewers
    if self.reviewer =~ /^\d+$/
      github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
      team_members = github.team_members(self.reviewer)
      team_members.map(&:login)
    else
      # it's just a single user
      Array(self.reviewer)
    end
  end
end

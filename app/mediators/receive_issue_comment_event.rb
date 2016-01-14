class ReceiveIssueCommentEvent
  include Sidekiq::Worker

  def perform(payload)
    @payload = payload

    comment = @payload["comment"]["body"]
    if comment_affirmative?(comment)
      self.approval_comment
    elsif comment_rebuild_reviews?(comment)
      self.rebuild_reviews
    end
  end

  def approval_comment
    return unless PullRequest.exists?(number: @payload["issue"]["number"])
    pr = PullRequest.pending_review.find_by(number: @payload["issue"]["number"])
    return unless pr.present?
    reviewers = pr.pending_reviews

    comment_author = @payload["sender"]["login"]
    return unless reviewers.include?(comment_author)

    comment = @payload["comment"]["body"]
    return unless comment_affirmative?(comment)

    reviewers.delete(comment_author)
    pr.pending_reviews = reviewers
    pr.completed_reviews << comment_author
    pr.save!

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    pull_resource = github.pull_request(ENV["CODY_GITHUB_REPO"], @payload["issue"]["number"])
    pr_sha = pull_resource.head.sha

    if pr.pending_reviews.none?
      github.create_status(
        @payload["repository"]["full_name"],
        pr_sha,
        "success",
        context: "code-review/cody",
        description: "Code review complete"
      )

      pr.status = "approved"
      pr.save!
    end
  end

  def rebuild_reviews
    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    pull_request = github.pull_request(@payload["repository"]["full_name"], @payload["issue"]["number"])

    CreateOrUpdatePullRequest.new.perform(pull_request)
  end

  # Checks if the given string can be taken as an affirmative review.
  #
  # Recognized approval phrases (all case insensitive):
  #
  # * "LGTM"
  # * ":+1:" # the GitHub thumbs-up emoji string
  # * "Looks good"
  # * "Looks good to me"
  #
  # comment - String to check
  #
  # Returns true if the comment is affirmative; false otherwise.
  def comment_affirmative?(comment)
    phrases = %w(
      lgtm
      looks\s+good(?:\s+to\s+me)?
    )

    # emojis need some extra processing so we handle them separately
    emojis = %w(
      \+1
      ok
      shipit
      rocket
      100
    ).map { |e| ":#{e}:\s*" }

    affirmatives = (phrases + emojis).map { |a| "(^#{a}$)" }
    joined = affirmatives.join("|")

    !!(comment =~ /#{joined}/i)
  end

  def comment_rebuild_reviews?(comment)
    comment == "!rebuild-reviews"
  end
end

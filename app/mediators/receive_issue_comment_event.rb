class ReceiveIssueCommentEvent
  include Sidekiq::Worker

  def perform(payload)
    @payload = payload
    return unless PullRequest.exists?(number: @payload["issue"]["number"])

    comment = @payload["comment"]["body"]
    if comment_affirmative?(comment)
      self.approval_comment
    elsif comment_rebuild_reviews?(comment)
      self.rebuild_reviews
    end
  end

  def approval_comment
    pr = PullRequest.pending_review.find_by(number: @payload["issue"]["number"])
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
      github.create_status(ENV["CODY_GITHUB_REPO"], pr_sha, "success", context: "code-review/cody", description: "Code review complete")

      pr.status = "approved"
      pr.save!
    end
  end

  def rebuild_reviews
    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    pull_resource = github.pull_request(ENV["CODY_GITHUB_REPO"], @payload["issue"]["number"])

    pr = PullRequest.find_by(number: @payload["issue"]["number"])

    author = pull_resource.user.login
    reviewers = pr.pending_reviews + pr.completed_reviews
    comment_author = @payload["sender"]["login"]
    return if comment_author != author && !reviewers.include?(comment_author)

    pr_sha = pull_resource.head.sha

    check_box_pairs = pull_resource.body.scan(/- \[([ x])\] @(\w+)/)

    if ENV["CODY_MIN_REVIEWERS_REQUIRED"] && check_box_pairs.count < ENV["CODY_MIN_REVIEWERS_REQUIRED"].to_i
      min_reviewers = ENV["CODY_MIN_REVIEWERS_REQUIRED"].to_i

      github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
      github.create_status(
        ENV["CODY_GITHUB_REPO"],
        pr_sha,
        "failure",
        context: "code-review/cody",
        description: "#{min_reviewers}+ reviewers are required",
        target_url: ENV["CODY_GITHUB_STATUS_TARGET_URL"]
      )

      return
    end

    pending_reviews = []
    completed_reviews = []

    check_box_pairs.each do |pair|
      if pair[0] == "x"
        completed_reviews << pair[1].strip
      else
        pending_reviews << pair[1].strip
      end
    end

    status = if pending_reviews.any?
      "pending_review"
    else
      "approved"
    end

    pr.status = status
    pr.pending_reviews = pending_reviews
    pr.completed_reviews = completed_reviews
    pr.save!

    commit_status = "pending"
    description = "Not all reviewers have approved. Comment \"LGTM\" to give approval."

    if pr.status == "approved"
      commit_status = "success"
      description = "Code review complete"
    end

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    github.create_status(
      ENV["CODY_GITHUB_REPO"],
      pr_sha,
      commit_status,
      context: "code-review/cody",
      description: description,
      target_url: ENV["CODY_GITHUB_STATUS_TARGET_URL"]
    )
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
    [
      /^lgtm$/i,
      /^:\+1:\s+$/, # if you select the emoji from the autocomplete, it inserts an extra space at the end
      /^:ok:$/,
      /^looks\s+good(?:\s+to\s+me)?$/i
    ].any? { |r| comment =~ r }
  end

  def comment_rebuild_reviews?(comment)
    comment == "!rebuild-reviews"
  end
end

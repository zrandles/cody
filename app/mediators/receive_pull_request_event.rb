class ReceivePullRequestEvent
  include Sidekiq::Worker

  def perform(payload)
    @payload = payload

    case @payload["action"]
    when "opened"
      self.on_opened(@payload["pull_request"])
    when "synchronize"
      self.on_synchronize
    end
  end

  def on_opened(pull_request_json)
    check_box_pairs = pull_request_json["body"].scan(/- \[([ x])\] @(\w+)/)

    pr_sha = pull_request_json["head"]["sha"]

    minimum_reviewers_required = Setting.lookup("minimum_reviewers_required")
    if minimum_reviewers_required.present? && check_box_pairs.count < minimum_reviewers_required
      github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
      github.create_status(
        ENV["CODY_GITHUB_REPO"],
        pr_sha,
        "failure",
        context: "code-review/cody",
        description: "APRICOT: Too few reviewers are listed",
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

    all_reviewers = pending_reviews + completed_reviews

    minimum_super_reviewers = Setting.lookup("minimum_super_reviewers")
    if minimum_super_reviewers.present?
      super_reviewers = Setting.lookup("super_reviewers")

      included_super_reviewers = all_reviewers.select { |r| super_reviewers.include?(r) }.count

      if included_super_reviewers < minimum_super_reviewers
        github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
        github.create_status(
          ENV["CODY_GITHUB_REPO"],
          pr_sha,
          "failure",
          context: "code-review/cody",
          description: "AVOCADO: PR does not meet super-review threshold",
          target_url: ENV["CODY_GITHUB_STATUS_TARGET_URL"]
        )

        return
      end
    end

    number = pull_request_json["number"]
    status = if pending_reviews.any?
      "pending_review"
    else
      "approved"
    end

    pr = PullRequest.create!(
      number: number,
      status: status,
      pending_reviews: pending_reviews,
      completed_reviews: completed_reviews
    )

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

  # The "synchronize" event occurs whenever a new commit is pushed to the branch
  # or the branch is rebased.
  #
  # In this case, we preserve the current review status and update the new
  # commit with the correct status indicator.
  def on_synchronize
    number = @payload["number"]

    if PullRequest.exists?(number: number)
      pr = PullRequest.find_by(number: number)

      status = "pending"
      description = "Not all reviewers have approved. Comment \"LGTM\" to give approval."

      if pr.status == "approved"
        status = "success"
        description = "Code review complete"
      end

      pr_sha = @payload["pull_request"]["head"]["sha"]

      github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
      github.create_status(
        ENV["CODY_GITHUB_REPO"],
        pr_sha,
        status,
        context: "code-review/cody",
        description: description,
        target_url: ENV["CODY_GITHUB_STATUS_TARGET_URL"]
      )
    end
  end
end

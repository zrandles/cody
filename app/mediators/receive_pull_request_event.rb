class ReceivePullRequestEvent
  include Sidekiq::Worker

  def perform(payload)
    @payload = payload

    case @payload["action"]
    when "opened"
      self.on_opened
    when "synchronize"
      self.on_synchronize
    end
  end

  def on_opened
    reviewers = @payload["pull_request"]["body"].scan(/- \[.\] @(\w+)/).flatten.map(&:strip)
    
    number = @payload["number"]

    PullRequest.create!(number: number, status: "pending_review", pending_reviews: reviewers)

    pr_sha = @payload["pull_request"]["head"]["sha"]

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    github.create_status(
      ENV["CODY_GITHUB_REPO"],
      pr_sha,
      "pending",
      context: "code-review/cody",
      description: "Not all reviewers have approved. Comment \"LGTM\" to give approval.",
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

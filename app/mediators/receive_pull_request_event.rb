class ReceivePullRequestEvent
  include Sidekiq::Worker

  def perform(payload)
    @payload = payload

    Raven.user_context(
      username: @payload["sender"]["login"]
    )
    Raven.tags_context(
      event: "pull_request",
      repo: @payload["repository"]["full_name"]
    )

    PaperTrail.whodunnit(@payload["sender"]["login"]) do
      case @payload["action"]
      when "opened"
        self.on_opened
      when "synchronize"
        self.on_synchronize
      end
    end
  end

  def on_opened
    pull_request = CreateOrUpdatePullRequest.new.perform(@payload["pull_request"])
    pull_request&.add_watchers
  end

  # The "synchronize" event occurs whenever a new commit is pushed to the branch
  # or the branch is rebased.
  #
  # In this case, we preserve the current review status and update the new
  # commit with the correct status indicator.
  def on_synchronize
    number = @payload["number"]
    repository = @payload["repository"]["full_name"]

    if pr = PullRequest.find_by(number: number, repository: repository)
      pr.update_status
    else
      CreateOrUpdatePullRequest.new.perform(@payload["pull_request"])
    end
  end
end

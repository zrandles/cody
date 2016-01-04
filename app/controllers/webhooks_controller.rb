class WebhooksController < ApplicationController
  def pull_request
    body = JSON.load(request.body)

    senders_whitelist = Setting.lookup("senders_whitelist")
    if senders_whitelist.present? && !senders_whitelist.include?(body["sender"]["login"])
      head :ok
      return
    end

    if body["action"] == "opened" || body["action"] == "synchronize"
      ReceivePullRequestEvent.perform_async(body.slice("action", "number", "pull_request", "repository"))
    end

    head :accepted
  end

  def issue_comment
    body = JSON.load(request.body)

    if body.key?("zen")
      head :ok
      return
    end

    ReceiveIssueCommentEvent.perform_async(body)
    head :accepted
  end
end

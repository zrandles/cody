class WebhooksController < ApplicationController
  def pull_request
    body = JSON.load(request.body)

    if body["action"] == "opened"
      ReceivePullRequestEvent.perform_async(body.slice("action", "number", "pull_request"))
    end

    head :accepted
  end

  def issue_comment
    body = JSON.load(request.body)
    ReceiveIssueCommentEvent.perform_async(body)
    head :accepted
  end
end

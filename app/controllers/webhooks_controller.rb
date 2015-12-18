class WebhooksController < ApplicationController
  def pull_request
    body = JSON.load(request.body)

    if body["action"] == "opened"
      ReceivePullRequestEvent.perform_async(body.slice("action", "number", "pull_request"))
    end

    head :accepted
  end
end

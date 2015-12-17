class WebhooksController < ApplicationController
  def pull_request
    ReceivePullRequestEvent.perform_async(params.slice("action", "number", "pull_request"))
    head :accepted
  end
end

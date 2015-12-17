require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe "POST pull_request" do
    it "delegates to ReceivePullRequestEvent" do
      expect { post :pull_request }.to change(ReceivePullRequestEvent.jobs, :size).by(1)
    end

    it "returns 202 Accepted" do
      post :pull_request
      expect(response.status).to be(202)
    end
  end
end

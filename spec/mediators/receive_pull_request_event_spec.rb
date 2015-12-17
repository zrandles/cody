require 'rails_helper'

RSpec.describe ReceivePullRequestEvent do
  let(:payload) { JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json"))) }

  let(:job) { ReceivePullRequestEvent.new }

  describe "#perform" do
    it "creates a new PullRequest" do
      expect { job.perform(payload) }.to change { PullRequest.count }.by(1)
    end
  end
end

require 'rails_helper'

RSpec.describe ReceivePullRequestEvent do
  let(:payload) { JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json"))) }

  let(:job) { ReceivePullRequestEvent.new }

  describe "#perform" do
    before do
      stub_request(:any, /https?:\/\/api\.github\.com\/.*/)
    end

    it "creates a new PullRequest" do
      expect { job.perform(payload) }.to change { PullRequest.count }.by(1)
    end

    it "sends a POST request to GitHub" do
      job.perform(payload)
      expect(WebMock).to have_requested(:post, %r(https?://api.github.com/repos/statuses/.*))
    end
  end
end

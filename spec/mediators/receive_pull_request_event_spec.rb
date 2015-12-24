require 'rails_helper'

RSpec.describe ReceivePullRequestEvent do
  let(:payload) do
    from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
    from_fixture["action"] = action
    from_fixture
  end

  let(:job) { ReceivePullRequestEvent.new }

  describe "#perform" do
    before do
      stub_request(:post, %r(https?://api.github.com/repos/\w+/\w+/statuses/[0-9abcdef]{40}))
    end

    context "when the action is \"opened\"" do
      let(:action) { "opened" }

      it "creates a new PullRequest" do
        expect { job.perform(payload) }.to change { PullRequest.count }.by(1)
      end

      it "sends a POST request to GitHub" do
        job.perform(payload)
        expect(WebMock).to have_requested(:post, %r(https?://api.github.com/repos/\w+/\w+/statuses/[0-9abcdef]{40}))
      end
    end

    context "when the action is \"synchronize\"" do
      let(:action) { "synchronize" }

      let!(:pr) { FactoryGirl.create :pull_request, number: payload["number"], status: status }

      before do
        job.perform(payload)
      end

      context "and the PR is pending" do
        let(:status) { "pending_review" }

        it "sends the pending review comment in the body" do
          expect(WebMock).to have_requested(:post, %r(https?://api.github.com/repos/\w+/\w+/statuses/[0-9abcdef]{40})).
            with { |req| JSON.load(req.body)["description"] == "Not all reviewers have approved. Comment \"LGTM\" to give approval." }
        end
      end

      context "and the PR is approved" do
        let(:status) { "approved" }

        it "sends the review complete comment in the body" do
          expect(WebMock).to have_requested(:post, %r(https?://api.github.com/repos/\w+/\w+/statuses/[0-9abcdef]{40})).
            with { |req| JSON.load(req.body)["description"] == "Code review complete" }
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ReceivePullRequestEvent do
  let(:payload) do
    from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
    from_fixture["action"] = action
    from_fixture["pull_request"]["body"] = body
    from_fixture
  end

  let(:job) { ReceivePullRequestEvent.new }

  let(:body) do
    "- [ ] @aergonaut\n- [ ] @BrentW\n"
  end

  describe "#perform" do
    before do
      stub_request(:post, %r(https?://api.github.com/repos/\w+/\w+/statuses/[0-9abcdef]{40}))
    end

    context "when the action is \"opened\"" do
      let(:action) { "opened" }

      context "when a minimum number of reviewers is required" do
        before do
          allow(ENV).to receive(:[]).and_call_original
          expect(ENV).to receive(:[]).with("CODY_MIN_REVIEWERS_REQUIRED").and_return(min_reviewers).at_least(:once)
        end

        context "and the PR does not have enough" do
          let(:min_reviewers) { "3" }

          it "puts the failure status on the commit" do
            job.perform(payload)
            expect(WebMock).to have_requested(:post, %r(https?://api.github.com/repos/\w+/\w+/statuses/[0-9abcdef]{40})).
              with { |req| JSON.load(req.body)["state"] == "failure" }
          end

          it "does not make a new PullRequest record" do
            expect { job.perform(payload) }.to_not change { PullRequest.count }
          end
        end
      end

      it "creates a new PullRequest" do
        expect { job.perform(payload) }.to change { PullRequest.count }.by(1)
      end

      context "when some reviewers have already approved" do
        let(:body) do
          "- [ ] @aergonaut\n- [x] @BrentW\n"
        end

        it "puts the ones that have already approved into the completed_reviews array" do
          job.perform(payload)
          expect(PullRequest.last.completed_reviews).to contain_exactly("BrentW")
        end
      end

      context "when all of the reviewers have already approved" do
        let(:body) do
          "- [x] @aergonaut\n- [x] @BrentW\n"
        end

        it "marks the status as approved" do
          job.perform(payload)
          expect(PullRequest.last.status).to eq("approved")
        end
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

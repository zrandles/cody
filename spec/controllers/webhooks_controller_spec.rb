require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe "POST pull_request" do
    let(:payload) do
      from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
      from_fixture["action"] = action
      from_fixture
    end

    let(:action) { "opened" }

    context "when the action is \"opened\"" do
      it "delegates to ReceivePullRequestEvent" do
        expect { post :pull_request, body: JSON.dump(payload) }.to change(ReceivePullRequestEvent.jobs, :size).by(1)
      end
    end

    context "when the action is not \"opened\"" do
      let(:action) { "closed" }

      it "does not create a new ReceivePullRequestEvent job" do
        expect { post :pull_request, body: JSON.dump(payload) }.to_not change(ReceivePullRequestEvent.jobs, :size)
      end
    end

    it "returns 202 Accepted" do
      post :pull_request, body: JSON.dump(payload)
      expect(response.status).to be(202)
    end

    context "when we are doing branch filtering" do
      before do
        allow(Setting).to receive(:lookup).and_call_original
        expect(Setting).to receive(:lookup).with("branch_filter").and_return(["foobar"])
        expect(Setting).to receive(:lookup).with("branch_filter_policy").and_return(:blacklist)
      end

      let(:payload) do
        from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
        from_fixture["action"] = action
        from_fixture["pull_request"]["base"]["ref"] = merge_base
        from_fixture
      end

      context "and the merge base falls in the blacklist" do
        let(:merge_base) { "foobar" }

        it "returns 200 OK" do
          post :pull_request, body: JSON.dump(payload)
          expect(response.status).to be(200)
        end

        it "does not create a new job" do
          expect { post :pull_request, body: JSON.dump(payload) }.to_not change(ReceivePullRequestEvent.jobs, :size)
        end
      end

      context "and the merge base is not in the blacklist" do
        let(:merge_base) { "master" }

        it "delegates to ReceivePullRequestEvent" do
          expect { post :pull_request, body: JSON.dump(payload) }.to change(ReceivePullRequestEvent.jobs, :size).by(1)
        end
      end
    end
  end

  describe "POST issue_comment" do
    let(:payload) { JSON.load(File.open(Rails.root.join("spec", "fixtures", "issue_comment.json"))) }

    it "creates a new ReceiveIssueCommentEvent job" do
      expect { post :issue_comment, body: JSON.dump(payload) }.to change(ReceiveIssueCommentEvent.jobs, :size).by(1)
    end

    it "returns 202 Accepted" do
      post :issue_comment, body: JSON.dump(payload)
      expect(response.status).to be(202)
    end
  end
end

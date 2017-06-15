require 'rails_helper'

RSpec.describe CreateOrUpdatePullRequest, type: :model do
  describe "#perform" do
    let(:payload) do
      from_fixture = json_fixture("pull_request")
      from_fixture["action"] = "opened"
      from_fixture["pull_request"]["body"] = body
      from_fixture["pull_request"]["number"] = 9876
      from_fixture["pull_request"]
    end
    let(:repo_full_name) { payload["base"]["repo"]["full_name"] }
    let(:head_sha) { payload["head"]["sha"] }

    context "linking to a parent PR" do
      let(:body) do
        "Reviewed in #1234"
      end

      let!(:parent_pr) { FactoryGirl.create :pull_request, status: "pending_review", number: 1234 }

      before do
        pr_9876 = json_fixture("pr")
        pr_9876["number"] = 9876
        pr_9876["head"]["sha"] = head_sha
        stub_request(:get, %r{https://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/9876}).to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: pr_9876.to_json
        )

        pr_1234 = json_fixture("pr")
        pr_1234["number"] = 1234
        stub_request(:get, %r{https://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/1234}).to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: pr_1234.to_json
        )

        stub_request(:post, "https://api.github.com/repos/#{repo_full_name}/statuses/#{head_sha}")
      end

      it "links the PR to the parent" do
        CreateOrUpdatePullRequest.new.perform(payload)
        expect(PullRequest.find_by(number: 9876).parent_pull_request).to eq(parent_pr)
      end

      it "posts the commit status" do
        CreateOrUpdatePullRequest.new.perform(payload)
        expect(WebMock).to have_requested(
          :post,
          "https://api.github.com/repos/#{repo_full_name}/statuses/#{head_sha}"
        ).with { |request|
            json_body = JSON.load(request.body)
            json_body["description"] == "Review is delegated to #1234"
          }
      end
    end
  end
end

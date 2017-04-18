require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  it { is_expected.to validate_numericality_of :number }
  it { is_expected.to validate_presence_of :number }
  it { is_expected.to validate_presence_of :repository }
  it { is_expected.to validate_presence_of :status }

  describe ".pending_review" do
    let(:pending_review_pr) { FactoryGirl.create :pull_request, status: "pending_review" }
    let(:approved_pr) { FactoryGirl.create :pull_request, status: "approved" }

    subject { PullRequest.pending_review }

    it { is_expected.to include(pending_review_pr) }
    it { is_expected.to_not include(approved_pr) }
  end

  let(:pr) { build :pull_request }

  it "only stores unique reviewers in pending reviews" do
    pr.pending_reviews = %w(aergonaut aergonaut BrentW)
    pr.save
    expect(pr.reload.pending_reviews).to contain_exactly("aergonaut", "BrentW")
  end

  describe "#update_status" do
    let(:pull_request_response_body) { JSON.load(Rails.root.join("spec", "fixtures", "pr.json")) }
    let(:pr_number) { pull_request_response_body["number"] }
    let(:repo_full_name) { pull_request_response_body["base"]["repo"]["full_name"] }
    let(:head_sha) { pull_request_response_body["head"]["sha"] }

    let(:pr) { build :pull_request, number: pr_number, repository: repo_full_name }

    before do
      stub_request(:get, "https://api.github.com/repos/#{repo_full_name}/pulls/#{pr_number}").to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: File.open(Rails.root.join("spec", "fixtures", "pr.json"))
      )
      stub_request(:post, "https://api.github.com/repos/#{repo_full_name}/statuses/#{head_sha}")
    end

    it "posts to the GitHub API" do
      pr.update_status
      expect(WebMock).to have_requested(:post, "https://api.github.com/repos/#{repo_full_name}/statuses/#{head_sha}")
    end
  end

  describe "#head_sha" do
    let(:pull_request_response_body) { JSON.load(Rails.root.join("spec", "fixtures", "pr.json")) }
    let(:pr_number) { pull_request_response_body["number"] }
    let(:repo_full_name) { pull_request_response_body["base"]["repo"]["full_name"] }
    let(:head_sha) { pull_request_response_body["head"]["sha"] }

    let(:pr) { build :pull_request, number: pr_number, repository: repo_full_name }

    before do
      stub_request(:get, "https://api.github.com/repos/#{repo_full_name}/pulls/#{pr_number}").to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: File.open(Rails.root.join("spec", "fixtures", "pr.json"))
      )
    end

    it "returns the SHA from the API response" do
      expect(pr.head_sha).to eq(head_sha)
    end
  end

  describe "#commit_authors" do
    let(:pr) { FactoryGirl.create :pull_request, status: "pending_review" }

    before do
      stub_request(:get, %r{https?://api.github.com/repos/aergonaut/testrepo/pulls/#{pr.number}/commits}).to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: File.open(Rails.root.join("spec", "fixtures", "pull_request_commits.json"))
      )
    end

    subject { pr.commit_authors }
    
    it 'returns array of commit authors' do
      expect(subject).to contain_exactly('aergonaut')
    end

    context 'without a repository' do
      # legacy case
      it "returns []" do
        allow(pr).to receive(:repository).and_return(nil)
        expect(pr.commit_authors).to be_empty
      end
    end
  end

  describe "#link_by_number" do
    let(:pr) { FactoryGirl.build :pull_request }
    let(:parent_number) { 1234 }

    context "when the parent PR is known to Cody" do
      let!(:parent) { FactoryGirl.create :pull_request, status: "pending_review", number: parent_number }

      it "returns truthy, sets the parent, copies the status, and persists the object" do
        expect(pr.link_by_number(parent_number)).to be_truthy
        expect(pr.parent_pull_request).to eq(parent)
        expect(pr.status).to eq(parent.status)
        expect(pr).to be_persisted
      end
    end

    context "when the parent PR is not known to Cody" do
      it "returns falsey, does not persist the object" do
        expect(pr.link_by_number(parent_number)).to be_falsey
        expect(pr).to_not be_persisted
      end
    end
  end

  describe "updating child PRs" do
    let!(:pr) { FactoryGirl.create :pull_request, status: "pending_review", number: 1234 }
    let!(:child) { FactoryGirl.build :pull_request }

    before do
      child_pr = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pr.json")))
      child_pr["number"] = child.number
      stub_request(:get, %r{https://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/#{child.number}}).to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: child_pr.to_json
      )

      pr_1234 = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pr.json")))
      pr_1234["number"] = 1234
      stub_request(:get, %r{https://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/1234}).to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: pr_1234.to_json
      )

      stub_request(:post, "https://api.github.com/repos/#{child.repository}/statuses/#{child.head_sha}")

      child.link_by_number(1234)
    end

    it "updates all child PRs when the status changes" do
      pr.status = "approved"
      pr.save!
      expect(child.reload.status).to eq(pr.status)
      expect(WebMock).to have_requested(:post, "https://api.github.com/repos/#{child.repository}/statuses/#{child.head_sha}")
        .with { |request|
          json_body = JSON.load(request.body)
          json_body["state"] == "success"
        }
    end
  end
end

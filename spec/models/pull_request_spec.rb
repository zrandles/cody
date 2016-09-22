require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  it { is_expected.to validate_numericality_of :number }
  it { is_expected.to validate_presence_of :number }
  it { is_expected.to validate_presence_of :repository }
  it { is_expected.to validate_presence_of :status }

  # it { is_expected.to serialize(:pending_reviews) }
  # it { is_expected.to serialize(:completed_reviews) }

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
end

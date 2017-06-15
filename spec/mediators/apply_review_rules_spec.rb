require 'rails_helper'

RSpec.describe ApplyReviewRules do
  let(:pull_request_hash) do
    {
      "number" => 42,
      "base" => {
        "repo" => {
          "full_name" => "aergonaut/testrepo"
        },
      },
      "body" => "Lorem ipsum\n"
    }
  end

  let(:job) { ApplyReviewRules.new(pr, pull_request_hash) }

  let(:pr) { FactoryGirl.create :pull_request }

  let(:rules) { FactoryGirl.create_list :review_rule, 2 }

  before do
    rules.each do |rule|
      expect(rule).to receive(:apply).and_return(true)
    end

    expect(ReviewRule).to receive(:for_repository).and_return(rules)

    expect(pr).to receive(:generated_reviewers).and_return(reviewers)

    # stub request to update PR body
    stub_request(:patch, "https://api.github.com/repos/aergonaut/testrepo/pulls/42").
      to_return(status: 200, body: "", headers: {})

    # stub request to update PR labels
    stub_request(:post, "https://api.github.com/repos/aergonaut/testrepo/issues/42/labels").
      to_return(status: 200, body: "", headers: {})
  end

  context "when reviewers were generated" do
    let(:reviewer) { FactoryGirl.build :reviewer, login: "octocat", review_rule: rules[0], pull_request: pr }
    let(:reviewers) { [reviewer] }

    let(:expected_addendum) do
      <<-ADDENDUM.chomp
## Generated Reviewers

#{reviewer.addendum}
ADDENDUM
    end

    it "updates the PR with the expected addendum" do
      job.perform

      expect(WebMock).to have_requested(
        :patch,
        "https://api.github.com/repos/aergonaut/testrepo/pulls/42"
      ).with(
        body: hash_including({
          body: pull_request_hash["body"].rstrip + "\n\n" + expected_addendum
        })
      )
    end
  end

  context "when no reviewers were generated" do
    let(:reviewers) { [] }

    it "does not make any requests" do
      job.perform

      expect(WebMock).to_not have_requested(
        :patch,
        "https://api.github.com/repos/aergonaut/testrepo/pulls/42"
      )
    end
  end
end

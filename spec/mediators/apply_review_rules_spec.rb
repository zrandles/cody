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

  let(:job) { ApplyReviewRules.new }

  before do
    expect(ReviewRule).to receive(:all).and_return(all_rules)

    stub_request(:patch, "https://api.github.com/repos/aergonaut/testrepo/pulls/42")
    stub_request(:post, "https://api.github.com/repos/aergonaut/testrepo/issues/42/labels")
  end

  context "when there are rules to apply" do
    let(:rule1) { instance_double(ReviewRule) }
    let(:rule2) { instance_double(ReviewRule) }
    
    let(:all_rules) { [rule1, rule2] }

    context "and some rules match" do
      before do
        expect(rule1).to receive(:apply).and_return("aergonaut")
        expect(rule1).to receive(:name).and_return("Foobar Review")

        expect(rule2).to receive(:apply).and_return(nil)
      end

      it "updates the PR body with the generated reviewers" do
        job.perform(pull_request_hash)
        expect(WebMock).to have_requested(
          :patch, "https://api.github.com/repos/aergonaut/testrepo/pulls/42"
        ).with { |request|
          updated_body = JSON.load(request.body)["body"]

          expected_addendum = <<-EOF
## Generated Reviewers

- [ ] @aergonaut (Foobar Review)
EOF

          updated_body == pull_request_hash["body"] + "\n\n" + expected_addendum
        }
      end

      it "adds labels to the PR" do
        job.perform(pull_request_hash)
        expect(WebMock).to have_requested(
          :post, "https://api.github.com/repos/aergonaut/testrepo/issues/42/labels"
        ).with { |request|
          labels = JSON.load(request.body)
          labels == ["Foobar Review"]
        }
      end
    end

    context "and multiple rules added the same reviewer" do
      before do
        expect(rule1).to receive(:apply).and_return("aergonaut")
        expect(rule1).to receive(:name).and_return("Foobar Review 1")

        expect(rule2).to receive(:apply).and_return("aergonaut")
        expect(rule2).to receive(:name).and_return("Foobar Review 2")
      end

      it "names the reviewer twice in the addendum" do
        job.perform(pull_request_hash)
        expect(WebMock).to have_requested(
          :patch, "https://api.github.com/repos/aergonaut/testrepo/pulls/42"
        ).with { |request|
          updated_body = JSON.load(request.body)["body"]

          expected_addendum = <<-EOF
## Generated Reviewers

- [ ] @aergonaut (Foobar Review 1)
- [ ] @aergonaut (Foobar Review 2)
EOF

          updated_body == pull_request_hash["body"] + "\n\n" + expected_addendum
        }
      end
    end

    context "and no rules match" do
      before do
        expect(rule1).to receive(:apply).and_return(nil)
        expect(rule2).to receive(:apply).and_return(nil)
      end

      it "makes no requests to the GitHub API" do
        job.perform(pull_request_hash)
        expect(WebMock).to_not have_requested(:any, %r{https?://api.github.com/.*})
      end
    end
  end

  context "when there are no review rules" do
    let(:all_rules) { [] }

    it "makes no requests to the GitHub API" do
      job.perform(pull_request_hash)
      expect(WebMock).to_not have_requested(:any, %r{https?://api.github.com/.*})
    end
  end
end

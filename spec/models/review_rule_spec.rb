require 'rails_helper'

RSpec.describe ReviewRule, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :reviewer }
  it { is_expected.to validate_presence_of :repository }

  let(:rule) { build :review_rule, reviewer: reviewer }

  describe ".for_repository" do
    let!(:rule1) { create :review_rule_always, repository: "aergonaut/testrepo" }
    let!(:rule2) { create :review_rule_always, repository: "aergonaut/cody" }

    subject { ReviewRule.for_repository("aergonaut/cody") }

    it { is_expected.to contain_exactly(rule2) }
    it { is_expected.to_not include(rule1) }
  end

  describe "#possible_reviewers" do
    context "when reviewer is a team ID" do
      let(:reviewer) { "1234" }

      before do
        stub_request(:get, %r{https?://api.github.com/teams/1234/members}).to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: File.open(Rails.root.join("spec", "fixtures", "team_members.json"))
        )
      end

      it "returns the list of team member logins" do
        expected_team_members = %w(aergonaut BrentW farrspace deepthisunder
          yatish27 h4hardikonly mityaz mpukas nazarik vovka torumori offtop)
        expect(rule.possible_reviewers).to contain_exactly(*expected_team_members)
      end
    end

    context "when reviewer is a username" do
      let(:reviewer) { "aergonaut" }

      it "just returns the username" do
        expect(rule.possible_reviewers).to eq(["aergonaut"])
      end
    end
  end

  describe "#add_reviewer" do
    let(:pr) { create :pull_request, pending_reviews: pending_reviews }

    let(:rule) { create :review_rule, reviewer: reviewer }

    before do
      expect(rule).to receive(:choose_reviewer).and_return(reviewer)
    end

    let(:reviewer) { "BrentW" }

    let(:pending_reviews) { ["aergonaut"] }

    it "returns the username that was added" do
      expect(rule.add_reviewer(pr)).to eq("BrentW")
    end

    it "adds the reviewer to the pending reviews" do
      rule.add_reviewer(pr)
      expect(pr.reviewers.pending_review.map(&:login)).to include(reviewer)
    end
  end

  describe "#apply" do
    let(:pull_request_hash) do
      {
        "number" => 42,
        'base' => {'repo' => {'full_name' => 'aergonaut/testrepo'}}
      }
    end

    let(:pr) { instance_double(PullRequest) }
    let(:rule) { build :review_rule, reviewer: "aergonaut" }

    before do
      expect(rule).to receive(:previously_applied?)
        .with(pr)
        .and_return(was_previously_applied)
    end

    context "when the rule was previously applied" do
      let(:was_previously_applied) { true }
      let(:does_match) { true }

      before do
        expect(rule).to_not receive(:matches?)
      end

      it "does not call add_reviewer again" do
        expect(rule).to_not receive(:add_reviewer)
        rule.apply(pr, pull_request_hash)
      end
    end

    context "when the rule was not previously applied" do
      let(:was_previously_applied) { false }

      before do
        expect(rule).to receive(:matches?)
          .with(pull_request_hash)
          .and_return(does_match)
      end

      context "and the rule matches" do
        let(:does_match) { true }

        it "calls add_reviewer" do
          expect(rule).to receive(:add_reviewer)
          rule.apply(pr, pull_request_hash)
        end
      end

      context "and the rule does not match" do
        let(:does_match) { false }

        it "does not call add_reviewer" do
          expect(rule).to_not receive(:add_reviewer)
          rule.apply(pr, pull_request_hash)
        end
      end
    end
  end

  describe "#previously_applied?" do
    let(:rule) { FactoryGirl.create :review_rule }
    let(:pr) { FactoryGirl.create :pull_request }

    subject { rule.previously_applied?(pr) }

    context "when the PR already has a reviewer that says it came from this rule" do
      before do
        FactoryGirl.create :reviewer, review_rule: rule, pull_request: pr
      end

      it { is_expected.to be_truthy }
    end

    context "when the PR does not have a reviewer that says it came from this rule" do
      it { is_expected.to be_falsey }
    end
  end
end

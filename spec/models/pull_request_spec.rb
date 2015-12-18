require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  it { is_expected.to validate_numericality_of :number }
  it { is_expected.to validate_presence_of :number }

  it { is_expected.to validate_presence_of :status }

  it { is_expected.to serialize(:pending_reviews) }
  it { is_expected.to serialize(:completed_reviews) }

  describe ".pending_review" do
    let(:pending_review_pr) { FactoryGirl.create :pull_request, status: "pending_review" }
    let(:approved_pr) { FactoryGirl.create :pull_request, status: "approved" }

    subject { PullRequest.pending_review }

    it { is_expected.to include(pending_review_pr) }
    it { is_expected.to_not include(approved_pr) }
  end
end

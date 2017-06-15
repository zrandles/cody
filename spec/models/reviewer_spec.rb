require 'rails_helper'
require 'securerandom'

RSpec.describe Reviewer, type: :model do
  describe "#addendum" do
    let(:context) { SecureRandom.hex }
    let(:reviewer) { FactoryGirl.build :reviewer, context: context }

    subject { reviewer.addendum }

    it { is_expected.to include(context) }

    it { is_expected.to match(%r{^- \[ \] @#{reviewer.login}$}) }

    it { is_expected.to include(reviewer.review_rule.name) }
  end

  describe "#status_to_check" do
    let(:reviewer) { FactoryGirl.build :reviewer, status: status }

    subject { reviewer.status_to_check }

    context "when pending review" do
      let(:status) { Reviewer::STATUS_PENDING_APPROVAL }

      it { is_expected.to eq(" ") }
    end

    context "when approved" do
      let(:status) { Reviewer::STATUS_APPROVED }

      it { is_expected.to eq("x") }
    end
  end
end

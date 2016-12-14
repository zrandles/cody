require 'spec_helper'
require_relative '../../app/models/review_rule_result'

RSpec.describe ReviewRuleResult do
  subject { ReviewRuleResult.new }

  it { is_expected.to respond_to(:reviewer) }
  it { is_expected.to respond_to(:context) }

  describe "#success?" do
    context "when a reviewer is present" do
      subject { ReviewRuleResult.new("aergonaut", "blah").success? }

      it { is_expected.to be_truthy }
    end

    context "when a reviewer is not present" do
      subject { ReviewRuleResult.new(nil, nil).success? }

      it { is_expected.to be_falsey }
    end
  end

  describe "#failure?" do
    context "when a reviewer is present" do
      subject { ReviewRuleResult.new("aergonaut", "blah").failure? }

      it { is_expected.to be_falsey }
    end

    context "when a reviewer is not present" do
      subject { ReviewRuleResult.new(nil, nil).failure? }

      it { is_expected.to be_truthy }
    end
  end
end

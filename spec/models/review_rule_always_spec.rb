require 'rails_helper'

RSpec.describe ReviewRuleAlways, type: :model do
  let(:rule) { build :review_rule_always, reviewer: "aergonaut" }
  describe "#matches?" do
    it "always returns true" do
      expect(rule.matches?).to be_truthy
    end
  end
end

require 'rails_helper'

RSpec.describe ReviewRuleAlways, type: :model do
  let(:rule) { build :review_rule_always, reviewer: "aergonaut" }
  describe "#matches?" do
    it "always returns the empty string" do
      expect(rule.matches?).to eq("  - This rule is always triggered")
    end
  end
end

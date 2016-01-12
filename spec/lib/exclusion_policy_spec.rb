require 'spec_helper'
require_relative '../../lib/exclusion_policy'

RSpec.describe ExclusionPolicy do
  describe "#permitted?" do
    let(:list) { %w(a b c d) }
    let(:policy) { ExclusionPolicy.new(list, policy_type) }

    context "when whitelisting" do
      let(:policy_type) { ExclusionPolicy::WHITELIST }

      it "disallows elements not in the list" do
        expect(policy.permitted?("e")).to be_falsey
      end

      it "allows elements in the list" do
        expect(policy.permitted?("a")).to be_truthy
      end
    end

    context "when blacklisting" do
      let(:policy_type) { ExclusionPolicy::BLACKLIST }

      it "allows elements not in the list" do
        expect(policy.permitted?("e")).to be_truthy
      end

      it "disallows elements in the list" do
        expect(policy.permitted?("a")).to be_falsey
      end
    end
  end
end

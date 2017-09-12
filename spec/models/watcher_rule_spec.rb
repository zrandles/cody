require 'rails_helper'

RSpec.describe WatcherRule, type: :model do

  let(:reviewer) { "aergonaut" }
  let(:rule) { create :watcher_rule, reviewer: reviewer, frequency: 0.8, repository: 'aergonaut/testrepo' }
  let(:pr) { create :pull_request }
  let(:pull_request_hash) do
    {
      "number" => 42,
      'base' => {'repo' => {'full_name' => 'aergonaut/testrepo'}}
    }
  end

  before do
    stub_request(:get, "https://api.github.com/repos/aergonaut/testrepo/pulls/1/commits")
  end
  
  describe "#matches?" do
    it "is true when random number < frequency" do
      allow(rule).to receive(:rand).and_return(0.79)
      expect(rule.matches?(pull_request_hash)).to be_truthy
    end

    it "is false when random number < frequency" do
      allow(rule).to receive(:rand).and_return(0.81)
      expect(rule.matches?(pull_request_hash)).to be_falsey
    end    
  end

  describe ".watcher_text" do
    let(:watcher_section) do
    <<~EOF
      ## Generated Shadow Reviewers

      - [ ] @zrandles

    EOF
    end

    it "returns a formatted reviewer @mention when available" do
      allow(WatcherRule).to receive(:single_watcher).and_return('zrandles')
      expect(WatcherRule.watcher_text(pr, pull_request_hash)).to eq watcher_section
    end

    it "returns an empty string when no reviewer is available" do
      allow(WatcherRule).to receive(:single_watcher).and_return(nil)
      expect(WatcherRule.watcher_text(pr, pull_request_hash)).to eq ""
    end
  end

  describe ".single_watcher" do
    let(:reviewer2) { "zrandles" }
    let(:rule2) { create :watcher_rule, reviewer: reviewer2, frequency: 1.0, repository: 'aergonaut/testrepo' }

    before do
      allow(pr).to receive(:commit_authors).and_return(['BrentW'])
    end

    it "returns nil when no rules match" do
      allow_any_instance_of(WatcherRule).to receive(:matches?).and_return(false)
      expect(WatcherRule.single_watcher(pr, pull_request_hash)).to be_nil
    end

    it "returns nil when the only matched rule is for the PR author" do
      allow(pr).to receive(:commit_authors).and_return(['zrandles'])
      rule.update_attribute(:frequency, 0.0)
      allow(rule2).to receive(:matches?).and_return(true)
      allow(rule2).to receive(:choose_reviewer).and_return(reviewer2)
      expect(WatcherRule.single_watcher(pr, pull_request_hash)).to be_nil
    end

    it "returns a random result when more than one watcher matches" do
      allow_any_instance_of(WatcherRule).to receive(:matches?).and_return(true)
      allow(rule).to receive(:choose_reviewer).and_return(reviewer2)
      allow(rule2).to receive(:choose_reviewer).and_return(reviewer)
      expect(['aergonaut', 'zrandles']).to include(WatcherRule.single_watcher(pr, pull_request_hash))
    end
  end
end

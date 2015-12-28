require 'rails_helper'

RSpec.describe Setting, type: :model do
  it { is_expected.to validate_presence_of :key }
  it { is_expected.to validate_uniqueness_of :key }
  it { is_expected.to validate_presence_of :value }

  describe ".assign" do
    it "writes the Transit format of the value to the setting" do
      Setting.assign("second_level_reviewers", ["aergonaut", "BrentW"])
      setting = Setting.find_by(key: "second_level_reviewers")
      expect(setting.value).to eq("[\"aergonaut\",\"BrentW\"]")
    end
  end

  describe ".lookup" do
    before do
      Setting.assign("second_level_reviewers", ["aergonaut", "BrentW"])
    end

    it "returns the value cast into the correct type" do
      expect(Setting.lookup("second_level_reviewers")).to be_a(Array)
    end

    it "returns nil when the key doesn't exist" do
      expect(Setting.lookup("not_a_real_key")).to be_nil
    end
  end
end

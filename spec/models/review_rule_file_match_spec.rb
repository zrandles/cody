require 'rails_helper'

RSpec.describe ReviewRuleFileMatch, type: :model do
  it { is_expected.to validate_presence_of :file_match }

  let(:rule) { build :review_rule_file_match, file_match: file_match }
  let(:file_match) { "db\/migrate" }
  
  describe "#file_match_regex" do
    it "returns a regex based on the file_match attribute" do
      expect(rule.file_match_regex).to eq(/#{file_match}/)
    end
  end

  describe "#matches?" do
    let(:pull_request_hash) do
      {
        "number" => "42",
        "repository" => {
          "full_name" => "aergonaut/testrepo"
        }
      }
    end

    let(:pull_request_files_body) do
      fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request_files.json")))

      fixture[0]["filename"] = filename
      JSON.dump(fixture)
    end

    before do
      stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/files}).to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: pull_request_files_body
      )
    end

    context "when one of the filenames matches" do
      let(:filename) { "db/migrate/#{Time.now.strftime "%Y%m%d%H%M%S"}_foobar.rb" }

      it "returns true" do
        expect(rule.matches?(pull_request_hash)).to be_truthy
      end
    end

    context "when none of the filenames match" do
      let(:filename) { "README.md" }

      it "returns true" do
        expect(rule.matches?(pull_request_hash)).to be_falsey
      end
    end
  end
end

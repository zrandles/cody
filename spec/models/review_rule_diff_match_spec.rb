require 'rails_helper'

RSpec.describe ReviewRuleDiffMatch, type: :model do
  it { is_expected.to validate_presence_of :file_match }

  let(:rule) { build :review_rule_diff_match, file_match: file_match }
  let(:file_match) { 'is[not ]* only a' }
  let(:patch) {"@@ -3,3 +3,5 @@\n This is only a test.\n \n Test more.\n+\n+90000"}
  
  describe "#file_match_regex" do
    it "returns a regex based on the file_match attribute" do
      expect(rule.file_match_regex).to eq(/#{file_match}/)
    end
  end

  describe "#matches?" do
    let(:pull_request_hash) do
      {
        "number" => "42",
        "base" => {
          "repo" => {
            "full_name" => "aergonaut/testrepo"
          }
        }
      }
    end

    let(:pull_request_files_body) do
      fixture = json_fixture("pull_request_files")

      fixture[0]["filename"] = filename
      fixture[0]["patch"] = patch

      JSON.dump(fixture)
    end

    before do
      stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/files}).to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: pull_request_files_body
      )
    end

    context "when one of the patches match" do
      let(:filename) { "db/migrate/#{Time.now.strftime "%Y%m%d%H%M%S"}_foobar.rb" }

      it "returns the filenames in an indented list" do
        expect(rule.matches?(pull_request_hash)).to eq("  - #{filename}")
      end
    end

    context "when several of the patches match" do
      let(:pull_request_files_body) do
        fixture = json_fixture("pull_request_files")

        fixture[0]["filename"] = filename

        other_file = fixture[0].dup
        other_file["filename"] = filename2
        fixture << other_file

        JSON.dump(fixture)
      end

      let(:filename) { "db/migrate/#{Time.now.strftime "%Y%m%d%H%M%S"}_foobar.rb" }
      let(:filename2) { "db/migrate/#{Time.now.strftime "%Y%m%d%H%M%S"}_fizzbuzz.rb" }

      it "returns the filenames in an indented list" do
        expect(rule.matches?(pull_request_hash)).to eq("  - #{filename}\n  - #{filename2}")
      end
    end

    context "when none of the filenames match" do
      let(:filename) { "README.md" }
      let(:patch) { '"@@ -3,3 +3,5 @@\n This is a test.\n \n Test more.\n+\n+90000"'}
      it "returns false" do
        expect(rule.matches?(pull_request_hash)).to be_falsey
      end
    end
  end
end

class ReviewRuleFileMatch < ReviewRule
  validates :file_match, presence: true

  def file_match_regex
    /#{self.file_match}/
  end

  def matches?(pull_request_hash)
    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    files = github.pull_request_files(pull_request_hash["base"]["repo"]["full_name"], pull_request_hash["number"])
    filenames = files.map(&:filename)

    filenames.any? { |filename| filename =~ self.file_match_regex }
  end
end

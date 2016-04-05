class ReviewRuleFileMatch < ReviewRule
  MAX_RETRIES = 3
  validates :file_match, presence: true

  def file_match_regex
    /#{self.file_match}/
  end

  def matches?(pull_request_hash)
    retries = 0
    begin
      github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
      files = github.pull_request_files(pull_request_hash["base"]["repo"]["full_name"], pull_request_hash["number"])
      filenames = files.map(&:filename)

      matched = filenames.select { |filename| filename =~ self.file_match_regex }

      if matched.any?
        matched.map { |fn| "  - #{fn}" }.join("\n")
      else
        false
      end
    rescue Octokit::NotFound => e
      if retries < MAX_RETRIES
        retries += 1
        Rails.logger.info "Request for files for PR ##{pull_request_hash["number"]} was 404, sleeping and retrying (retries = #{retries})"
        sleep(1)
        retry
      else
        raise e
      end
    end
  end
end

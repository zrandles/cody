module GithubApi
  extend ActiveSupport::Concern

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
  end
end

module GithubApi
  extend ActiveSupport::Concern

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: Rails.application.secrets.github_access_token)
  end
end

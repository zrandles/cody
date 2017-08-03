require "aws-sdk"

module GithubApi
  extend ActiveSupport::Concern

  private

  def github_client
    @github_client ||= Octokit::Client.new(
      access_token: Rails.application.secrets.github_access_token
    )
  end

  def integration_client(installation_id:)
    jwt_token = make_jwt_token
    bearer_client = Octokit::Client.new(bearer_token: jwt_token)
    access_token = bearer_client.create_app_installation_access_token(
      installation_id
    )
    Octokit::Client.new(access_token: access_token.token)
  end

  def make_jwt_token
    private_key = integration_private_key

    payload = {
      iat: Time.now.to_i,
      exp: 10.minutes.from_now.to_i,
      iss: ENV["CODY_GITHUB_INTEGRATION_IDENTIFIER"]
    }

    JWT.encode(payload, private_key, "RS256")
  end

  # Read the integration's private key from the environment.
  #
  # If CODY_GITHUB_INTEGRATION_PRIVATE_KEY is specified, this variable is
  # assumed to contain the contents of the .pem file and is used as is.
  #
  # If CODY_GITHUB_INTEGRATION_PRIVATE_KEY_PATH is specified, this variable is
  # assumed to contain the path to the .pem file. Relative paths are expanded
  # relative to Rails.root.
  def integration_private_key
    ENV["CODY_GITHUB_INTEGRATION_PRIVATE_KEY"].presence ||
      File.read(
        Rails.root.join(ENV["CODY_GITHUB_INTEGRATION_PRIVATE_KEY_PATH"])
          .expand_path
      )
  end
end

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
    aws = Aws::S3::Client.new(
      access_key_id: Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key
    )
    response = aws.get_object(
      bucket_name: ENV["PEM_BUCKET"],
      key: ENV["INTEGRATION_PEM"]
    )
    private_key = response.body.read

    payload = {
      iat: Time.now.to_i,
      exp: 10.minutes.from_now.to_i,
      iss: ENV["CODY_GITHUB_INTEGRATION_IDENTIFIER"]
    }

    JWT.encode(payload, private_key, "RS256")
  end
end

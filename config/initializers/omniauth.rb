Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    Rails.application.secrets.github_integration_client_id,
    Rails.application.secrets.github_integration_client_secret
end

module OmniauthHelpers
  def mock_auth(provider, auth_hash)
    OmniAuth.config.add_mock(provider, auth_hash)
  end
end

RSpec.configure do |config|
  config.include OmniauthHelpers
end

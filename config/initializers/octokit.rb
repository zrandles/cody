stack = Faraday::RackBuilder.new do |builder|
  builder.response :logger
  builder.use Octokit::Middleware::FollowRedirects
  builder.use Octokit::Response::RaiseError
  builder.use Octokit::Response::FeedParser
  builder.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger, shared_cache: false, serializer: Marshal
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack

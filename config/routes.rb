Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/webhooks/pull_request' => 'webhooks#pull_request'
  post '/webhooks/issue_comment' => 'webhooks#issue_comment'
end

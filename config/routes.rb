Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/webhooks/pull_request' => 'webhooks#pull_request'
  post '/webhooks/issue_comment' => 'webhooks#issue_comment'
  post '/webhooks/integration' => 'webhooks#integration'

  # Mirror GitHub's URL structure for Pull Requests
  resources :pulls, only: %i(index)
  resources :pull, only: %i(show update), controller: :pulls

  resources :sessions

  get '/auth/:provider/callback' => 'sessions#create'

  root 'pulls#index'
end

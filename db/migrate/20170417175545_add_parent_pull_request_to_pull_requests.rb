class AddParentPullRequestToPullRequests < ActiveRecord::Migration[5.0]
  def change
    add_reference :pull_requests, :parent_pull_request, index: true
  end
end

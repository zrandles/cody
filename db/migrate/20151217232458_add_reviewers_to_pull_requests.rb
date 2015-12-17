class AddReviewersToPullRequests < ActiveRecord::Migration
  def change
    add_column :pull_requests, :pending_reviews, :string
    add_column :pull_requests, :completed_reviews, :string
  end
end

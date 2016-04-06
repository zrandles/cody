class AddRepositoryToPullRequest < ActiveRecord::Migration
  def change
    add_column :pull_requests, :repository, :string
  end
end

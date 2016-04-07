class AddRepositoryToReviewRules < ActiveRecord::Migration
  def change
    add_column :review_rules, :repository, :string
  end
end

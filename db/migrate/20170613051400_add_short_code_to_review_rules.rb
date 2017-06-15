class AddShortCodeToReviewRules < ActiveRecord::Migration[5.1]
  def change
    add_column :review_rules, :short_code, :string
  end
end

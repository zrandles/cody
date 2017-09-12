class AddPercentageToReviewRule < ActiveRecord::Migration[5.1]
  def up
    add_column :review_rules, :frequency, :decimal, default: 1.0 unless column_exists?(:review_rules, :frequency)
  end

  def down
    remove_column :review_rules, :frequency if column_exists?(:review_rules, :frequency)
  end
end

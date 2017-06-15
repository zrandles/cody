class CreateReviewers < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewers do |t|
      t.string :login
      t.string :status
      t.text :context
      t.references :review_rule
      t.references :pull_request

      t.timestamps
    end
  end
end

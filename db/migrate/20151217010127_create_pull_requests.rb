class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.string :status
      t.string :number

      t.timestamps null: false
    end
  end
end

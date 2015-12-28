class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
    end

    add_index :settings, [:key, :value], unique: true
  end
end

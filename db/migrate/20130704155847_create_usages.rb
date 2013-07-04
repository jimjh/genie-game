class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usages do |t|
      t.integer :use_count, default: 0
      t.references :user
      t.references :lesson
      t.timestamps
    end
    add_index :usages, :user_id
    add_index :usages, :lesson_id
  end
end

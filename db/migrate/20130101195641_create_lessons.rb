class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :name
      t.references :user
      t.string :url

      t.timestamps
    end
    add_index :lessons, :user_id
  end
end

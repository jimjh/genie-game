class AddHookToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :hook, :string
  end
end

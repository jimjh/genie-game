class AddPathsToLessons < ActiveRecord::Migration

  def change
    add_column :lessons, :compiled_path, :string, null: true
    add_column :lessons, :solution_path, :string, null: true
  end

end

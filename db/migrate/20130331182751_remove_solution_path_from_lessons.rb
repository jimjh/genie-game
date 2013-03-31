class RemoveSolutionPathFromLessons < ActiveRecord::Migration

  def change
    remove_column :lessons, :solution_path
  end

end

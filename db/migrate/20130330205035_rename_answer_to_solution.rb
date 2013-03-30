class RenameAnswerToSolution < ActiveRecord::Migration

  def change
    rename_column :problems, :answer, :solution
  end

end

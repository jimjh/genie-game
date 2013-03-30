class RenameQuestionsToProblems < ActiveRecord::Migration

  def change
    rename_table :questions, :problems
    rename_index :questions, 'index_questions_on_digest', 'index_problems_on_digest'
    rename_index :questions, 'index_questions_on_lesson_id', 'index_problems_on_lesson_id'
    rename_index :questions, 'index_questions_on_position', 'index_problems_on_position'
  end

end

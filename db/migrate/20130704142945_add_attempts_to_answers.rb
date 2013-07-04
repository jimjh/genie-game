class AddAttemptsToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :attempts, :integer, default: 0
    add_column :answers, :first_correct_attempt, :integer, null: true
  end
end

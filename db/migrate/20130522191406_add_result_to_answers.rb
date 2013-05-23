class AddResultToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :results, :string,  null: false, default: ''
    add_column :answers, :score,   :integer, null: false, default: 0
  end
end

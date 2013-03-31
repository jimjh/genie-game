class CreateAnswers < ActiveRecord::Migration

  def change

    create_table :answers do |t|
      t.references :problem
      t.references :user
      t.string     :content
      t.timestamps
    end

    add_index :answers, :problem_id
    add_index :answers, :user_id

  end

end

class CreateQuestions < ActiveRecord::Migration

  def change

    create_table :questions do |t|
      t.string  :digest,    null: false
      t.integer :position,  null: false
      t.references :lesson, null: false
      t.binary  :answer
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :questions, :lesson_id
    add_index :questions, :digest
    add_index :questions, :position

  end

end

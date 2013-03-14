class AddStatusToLessons < ActiveRecord::Migration

  def change
    add_column :lessons, :status, :string, null: false, default: 'created'
  end

end

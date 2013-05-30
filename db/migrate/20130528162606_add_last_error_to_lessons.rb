class AddLastErrorToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :last_error, :string
  end
end

class AddOwnerToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :owner, :string
  end
end

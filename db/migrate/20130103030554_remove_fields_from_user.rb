class RemoveFieldsFromUser < ActiveRecord::Migration

  def change
    remove_column :users, :nickname
    remove_column :users, :name
    add_column    :authorizations, :nickname, :string
  end

end

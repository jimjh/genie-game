class ChangeContentToBinary < ActiveRecord::Migration

  def change
    change_column :answers, :content, :binary
  end

end

class ConvertDigestToBinary < ActiveRecord::Migration

  def change
    remove_index  :problems, :digest
    change_column :problems, :digest, :binary
  end

end

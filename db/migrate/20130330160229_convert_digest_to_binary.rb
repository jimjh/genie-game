class ConvertDigestToBinary < ActiveRecord::Migration

  def change
    change_column :problems, :digest, limit: 32
    change_column :problems, :digest, :binary
  end

end

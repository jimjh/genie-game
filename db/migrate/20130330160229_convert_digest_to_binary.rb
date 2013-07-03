class ConvertDigestToBinary < ActiveRecord::Migration

  def change
    change_column :problems, :digest, :binary, :limit => 32
  end

end

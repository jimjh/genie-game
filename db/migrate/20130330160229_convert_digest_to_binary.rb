class ConvertDigestToBinary < ActiveRecord::Migration

  def change
    change_column :problems, :digest, :binary
  end

end

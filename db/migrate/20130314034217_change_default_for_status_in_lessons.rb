class ChangeDefaultForStatusInLessons < ActiveRecord::Migration

  def change
    change_column_default :lessons, :status, 'publishing'
  end

end

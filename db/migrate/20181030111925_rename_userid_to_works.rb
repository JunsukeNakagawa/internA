class RenameUseridToWorks < ActiveRecord::Migration[5.1]
  def change
    rename_column :works, :userid, :user_id
  end
end

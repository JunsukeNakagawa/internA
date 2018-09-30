class RemoveAddSuperiorToUsersFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :AddSuperiorToUsers, :string
  end
end

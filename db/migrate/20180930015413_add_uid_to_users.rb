class AddUidToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :uid, :integer
    add_column :users, :AddSuperiorToUsers, :string
    add_column :users, :superior, :integer
  end
end
class AddCardIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cardID, :integer
  end
end

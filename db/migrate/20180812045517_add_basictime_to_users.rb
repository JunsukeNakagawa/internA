class AddBasictimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basictime, :time
  end
end

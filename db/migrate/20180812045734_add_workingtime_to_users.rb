class AddWorkingtimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :workingtime, :time
  end
end

class AddBasictimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_work_time, :time
  end
end

class AddWorkingTimeEndToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :working_time_End, :datetime
  end
end

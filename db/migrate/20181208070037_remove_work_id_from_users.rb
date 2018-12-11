class RemoveWorkIdFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :work_id, :integer
  end
end

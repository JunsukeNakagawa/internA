class AddUidToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :integer
    add_column :users, :AddSuperiorToUsers, :string
    add_column :users, :superior, :boolean
  end
end

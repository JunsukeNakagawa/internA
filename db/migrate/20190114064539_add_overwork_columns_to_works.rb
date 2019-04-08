class AddOverworkColumnsToWorks < ActiveRecord::Migration[5.1]
  def change
    add_column :works, :authorizer_user_id, :integer
    add_column :works, :application_state, :integer
    add_column :works, :overtime_work, :text
    add_column :works, :edited_work_start, :datetime
    add_column :works, :edited_work_end, :datetime
    add_column :works, :application_edit_state, :integer
    add_column :works, :authorizer_user_id_of_attendance, :integer
    add_column :works, :before_edited_work_start, :datetime
    add_column :works, :before_edited_work_end, :datetime
  end
end

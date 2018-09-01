class RenameAttendanceTimeEditColumnToWorks < ActiveRecord::Migration[5.1]
  def change
    rename_column :works, :attendance_time_edit, :workingtime
    rename_column :works, :leaving_time_edit, :basictime
  end
end

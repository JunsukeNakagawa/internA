class AddScheduledEndtimeToWorks < ActiveRecord::Migration[5.1]
  def change
    add_column :works, :scheduled_end_time, :datetime
    add_column :works, :AddCheckboxToWorks, :string
    add_column :works, :checkbox, :boolean
    add_column :works, :AddWorkingDescriptionToWorks, :string
    add_column :works, :work_description, :text
    add_column :works, :AddCheckbyBossToWorks, :string
    add_column :works, :check_by_boss, :integer
  end
end

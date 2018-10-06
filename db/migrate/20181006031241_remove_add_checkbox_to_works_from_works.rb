class RemoveAddCheckboxToWorksFromWorks < ActiveRecord::Migration[5.1]
  def change
    remove_column :works, :AddCheckboxToWorks, :string
    remove_column :works, :AddWorkingDescriptionToWorks, :string
    remove_column :works, :AddCheckbyBossToWorks, :string
  end
end

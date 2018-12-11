class WorksController < ApplicationController
  
  def new
  end
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
  def apply_overwork
    @work = Work.find_by(day: params[:work][:day], user_id: current_user.id)
    if params[:work][:checkbox] == "true"
      date_tomorrow = time_change.tomorrow - 9.hours
      @work.update_attributes(apply_overwork_params)
      @work.update(scheduled_end_time: date_tomorrow)
    else
      @work.update_attributes(apply_overwork_params)
      @work.update(scheduled_end_time: time_change - 9.hours)
    end
    flash[:success] = "残業申請しました。"
    redirect_to user_path(current_user, Date.today)
  end
  
  def apply_attendance
  end
  
  private

  def apply_overwork_params
    params.require(:work).permit(:scheduled_end_time, :checkbox, :work_description, :check_by_boss, :day)
  end
  
  def time_change
    day = params[:work][:day].to_datetime
    time = params[:work][:scheduled_end_time].to_datetime
    Time.new(day.year,day.month,day.day,time.hour,time.min,time.sec)
  end
    



end

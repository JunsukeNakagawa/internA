class WorksController < ApplicationController
  def new
   if logged_in?
     @user  = current_user 
   end
   if @work.nil?
    @work = Work.new
   end
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
  end
  
  def attend
    @work = Work.find_by(day: Date.today)
    @work.attendance_time = Time.now
    if @work.save
      flash[:notice] = "出社時間を登録しました"
      redirect_to("/works/new")
    else
      render("works/edit")
    end
  end
  
  def edit
    @work = Work.find_by(id: params[:id])
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
  end
  
  def update
    #@user = User.find(params[:id])
    @work = Work.find_by(user_id: @user.id)
    #@work.attendance_time = params[:attendance_time]
    #@work.leaving_time = params[:leaving_time]
    unless @work.nil?
      if @work.update_attributes(work_params)
        flash[:notice] = "勤怠時間を編集しました"
        redirect_to current_user
      end
    end
  end
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
end

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
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.attendance_time = Time.now
    if @work.save
      flash[:notice] = "出社時間を登録しました"
      redirect_to("/works/new")
    else
      render("works/edit")
    end
  end
  
  def leave
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.leaving_time = Time.now
    if @working_days.nil?
    end
    if @work.save
      flash[:notice] = "退社時間を登録しました"
      redirect_to("/works/new")
    else
      render("works/edit")
    end
  end
  
  def edit
    @work = Work.find_by(id: current_user.id)
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
  end
  
  def update
    @work = Work.find_by(userid: current_user.id)
    @work.attendance_time = params[:attendance_time]
    @work.leaving_time = params[:leaving_time]
    if @work.save
        flash[:notice] = "勤怠時間を編集しました"
        redirect_to("/works/edit")
      else
        flash[:notice] = "編集に失敗しました"
        redirect_to("/works/edit")
    end
  end
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
end

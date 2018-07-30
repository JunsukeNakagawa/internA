class WorksController < ApplicationController
  def new
   if logged_in?
     @user  = current_user 
   end
	
   if @work.nil?
     @work = Work.new
   end
    # 表示月があれば取得
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # 表示月がなければ今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
     #今月末のデータを取得
     @last_day = @first_day.end_of_month
  end
  
  def edit
    @work = Work.find_by(id: params[:id])
  end
  
  def update
    @work = Work.find_by(id: params[:id])
    @work.attendance_time = params[:attendance_time]
    @work.leaving_time = params[:leaving_time]
    if @work.save
      flash[:notice] = "編集しました"
      redirect_to("/works/new")
    else
      render("works/edit")
    end
  end
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
  def attend
   if logged_in?
     @user  = current_user 
   end
   if @work.nil?
     @work = Work.new(attendance_time: Time.current)
   end
    if @work.save
      flash[:notice] = "出社時間を登録しました"
      redirect_to("/works/new")
    else
      render("works/edit")
    end
  end
end

class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end
  
  def attendance_display
   if logged_in?
     @user  = current_user 
   end
	
   if @attendance.nil?
     @attendance = Attendance.new(day: Date.current)
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
  
  def attendance_edit
    if logged_in?
     @user  = current_user 
    end
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
  
end

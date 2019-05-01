class WorksController < ApplicationController
  
  def new
  end
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
  def edit
    if current_user.admin?
      redirect_to :action => 'index'
    end
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @youbi = %w[日 月 火 水 木 金 土]
    # 上長ユーザを全取得
    ids = [@user.applied_last_time_user_id]
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact
    
    # 表示月があれば取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # ないなら今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    @last_day = @first_day.end_of_month
    
    # 期間分のデータチェック
    (@first_day..@last_day).each do |date|
      # 該当日付のデータがないなら作成する
      if !@user.attendances.any? {|attendance| attendance.day == date }
        attend = Attendance.create(user_id: @user.id, day:date)
        attend.save
      end
    end
    
    # 表示期間の勤怠データを日付順にソートして取得
    @attendances = @user.attendances.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
  end
  
  # 残業を申請する
  def overtime_application
    @user = User.find(params[:id])
    
    # 変更チェックが1つ以上で各残業申請情報を更新
    if !params[:check].blank?
      params[:attendance].each do |id, item|
        # 更新チェックがなければ何もしない
        if !params[:check].include?(id)
          next
        end
        
        attendance = Work.find(id)
        # 申請者が入力されていたら『申請中』に変更する
        if !item[:authorizer_user_id].blank?
          attendance.applying!
          # 申請者の番号も保持
          @user.update_attributes(applied_last_time_user_id: item[:authorizer_user_id])
        else
          # 空なら上書きで空とならないよう既存のものをセット
          item[:authorizer_user_id] = attendance.authorizer_user_id
        end
        attendance.update_attributes(item.permit(:work_description, :authorizer_user_id, :application_state))
        
        # 終了予定時間があれば更新
        if !item["scheduled_end_time(4i)"].blank? || !item["scheduled_end_time(5i)"].blank?
          attendance.update_column(:scheduled_end_time, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, item["scheduled_end_time(4i)"].to_i, item["scheduled_end_time(5i)"].to_i))
        end
      end
    else
      flash[:danger] = "変更チェックにチェックをいれてください"
    end
    
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
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
    redirect_to user_url
  end
  
  # 1日分の残業を申請する
  def one_overtime_application
    @user = User.find(params[:work][:user_id])
    
    # 終了予定時刻が空なら何もしない
    if params[:work]["scheduled_end_time(4i)"].blank? || params[:work]["scheduled_end_time(5i)"].blank?
      flash[:danger] = "残業申請の終了予定時刻が空です"
      redirect_to user_url(@user, params: { id: @user.id, first_day: params[:work][:first_day] })
      return
    end
    
    # 申請先が空なら何もしない
    if params[:work][:authorizer_user_id].blank?
      flash[:danger] = "残業申請の申請先が空です"
      redirect_to user_url(@user, params: { id: @user.id, first_day: params[:work][:first_day] })
      return
    end
    
    attendance = Work.find(params[:work][:id])
    # 申請者が入力されていたら『申請中』に変更する
    if !params[:work][:authorizer_user_id].blank?
      attendance.applying!
      # 申請者の番号も保持
      @user.update_attributes(applied_last_time_user_id: params[:work][:authorizer_user_id])
    else
      # 空なら上書きで空とならないよう既存のものをセット
      params[:work][:authorizer_user_id] = attendance.authorizer_user_id
    end
    attendance.update_attributes(params.require(:work).permit(:work_description, :authorizer_user_id, :application_state))
    
    # 終了予定時間があれば更新
    if !params[:work]["scheduled_end_time(4i)"].blank? || !params[:work]["scheduled_end_time(5i)"].blank?
      attendance.update_column(:scheduled_end_time, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, params[:work]["scheduled_end_time(4i)"].to_i, params[:work]["scheduled_end_time(5i)"].to_i))
    end
    
    # 翌日チェックONなら終了予定時間を＋1日する
    if !params[:checkbox].blank?
      attendance.update_column(:scheduled_end_time, attendance.scheduled_end_time+1.day)
    end
    
    flash[:success] = "残業申請完了しました"
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:work][:first_day] })
  end
  
  # 申請された1ヵ月分の勤怠を更新する（承認/否認など）
  def update_onemonth_applied_attendance
    
    # 変更チェックが1つ以上で勤怠変更情報を更新
    if !params[:check].blank?
      params[:application].each do |id, item|
        # 更新チェックがなければ何もしない
        if !params[:check].include?(id)
          next
        end
        
        attendance = OneMonthAttendance.find(id)
        if attendance.blank?
          next
        end
        # 申請情報更新
        attendance.update_attributes(item.permit(:application_state))
      end
    else
      flash[:danger] = "変更チェックにチェックをいれてください"
    end

    @user = User.find(params[:id])
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
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

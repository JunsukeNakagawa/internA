class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  # before_action :show_user, only: [:show, :attendancetime_edit, :attendancetime_update]
  # before_action :correct_user,   only: [:edit, :update]
  before_action :admin_or_correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :timeupdate, :update ]
  
  require 'csv'
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
    @user = User.new
  end
  
  def show
    if current_user.admin?
      redirect_to :action => 'index'
    end
    
    if logged_in?
      @user = current_user
    end
   
    if @work.nil?
      @work = Work.new
    end
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    # 曜日表示用に使用する
    @youbi = %w[日 月 火 水 木 金 土]
    # 基本情報取得
    # @basic_info = BasicInfo.find_by(id: 1)
    # 表示月があれば取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # ないなら今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    @last_day = @first_day.end_of_month
    # 表示期間の勤怠データを日付順にソートして取得
    @works = @user.works.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
    # 出勤日数を取得
    @working_days = @works.where.not(attendance_time: nil, leaving_time: nil).count

    # 在社時間の総数を取得
    @work_sum = 0
    @works.where.not(attendance_time: nil, leaving_time: nil).each do |work|
      @work_sum += work.leaving_time - work.attendance_time
      # 自分に申請中の残業一覧を取得
      @attendances_over = @works.where.not(scheduled_end_time: nil, authorizer_user_id: nil)
    end
    @work_sum /= 3600
    
    # 上長ユーザを全取得 @note 自分以外の上長を取得
    ids = [@user.applied_last_time_user_id]
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact
    
    # 自身の所属長承認状態取得
    @one_month_attendance = OneMonthAttendance.find_by(application_user_id: @user.id, application_date: @first_day)
    # 申請用に新規作成
    @new_one_month_attendance = OneMonthAttendance.new(application_user_id: @user.id)

    # 自分に申請中の勤怠編集一覧を取得
    @edit_applications_to_me = Work.where(authorizer_user_id_of_attendance: @user.id, application_edit_state: :applying1)
    # 存在しないuserは除外
    @edit_applications_to_me = @edit_applications_to_me.select{ |x| !User.find_by(id: x.user_id).nil? }
    # 名前ごとに分類
    @edit_applications = @edit_applications_to_me.group_by do |application|
      User.find_by(id: application.user_id).name
    end

    # 承認済みの勤怠編集一覧を取得
    @edit_log_applications = Work.where(user_id: @user.id, application_edit_state: :approval2)
    # 名前ごとに分類
    @edit_log_applications = @edit_log_applications.group_by do |application|
      User.find_by(id: application.user_id).name
    end

    # 自分に申請中の残業一覧を取得
    @applications_to_me = Work.where(authorizer_user_id: @user.id, application_state: :applying)
    # 存在しないuserは除外
    @applications_to_me = @applications_to_me.select{ |x| !User.find_by(id: x.user_id).nil? }
    # 名前ごとに分類
    @overtime_applications = @applications_to_me.group_by do |application|
      User.find_by(id: application.user_id).name
    end

    # 所属長承認の情報取得
    @one_month_applications_to_me = OneMonthAttendance.where(authorizer_user_id: @user.id, application_state: :applying)
    # 存在しないuserは除外
    @one_month_applications_to_me = @one_month_applications_to_me.select{ |x| !User.find_by(id: x.application_user_id).nil? }
    # 名前ごとに分類
    @one_month_applications = @one_month_applications_to_me.group_by do |application|
      User.find_by(id: application.application_user_id).name
    end

    # CSV出力ファイル名を指定
    respond_to do |format|
      format.html
      format.csv do
        attendance_CSV_output
      end
    end
  end
  
  def show_confirm
    @user = User.find(params[:id])
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
  end
  
  def csv_output
    @user = User.new
  end
  
  def user_attendance_output
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @youbi = %w[日 月 火 水 木 金 土]
    # 基本情報取得
    # @basic_info = BasicInfo.find_by(id: 1)
    # 表示月があれば取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # ないなら今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    @last_day = @first_day.end_of_month
    # 表示期間の勤怠データを日付順にソートして取得
    @works = @user.works.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
    # 出勤日数を取得
    @working_days = @works.where.not(attendance_time: nil, leaving_time: nil).count

    # 在社時間の総数を取得
    @work_sum = 0
    @works.where.not(attendance_time: nil, leaving_time: nil).each do |work|
      @work_sum += work.leaving_time - work.attendance_time
      # 自分に申請中の残業一覧を取得
      @attendances_over = @works.where.not(scheduled_end_time: nil, authorizer_user_id: nil)
    end
    @work_sum /= 3600

    # CSV出力ファイル名を指定
    respond_to do |format|
      # format.html
      format.csv do
        send_data render_to_string, filename: "#{@first_day.strftime("%Y年%m月")}_#{@user.name}.csv", type: :csv
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def attend
    @work = Work.find_by(day: Date.today, user_id: current_user.id)
    @work.attendance_time = Time.new(Time.now.year,Time.now.month,Time.now.day,Time.new.hour,Time.now.min,00)
    if @work.save
      flash[:success] = "出社時間を登録しました"
      redirect_to user_path
    else
      flash[:info] = "失敗しました。"
      redirect_to root_url
    end
  end
  
  def leave
    @work = Work.find_by(day: Date.today, user_id: current_user.id)
    @work.leaving_time = Time.new(Time.now.year,Time.now.month,Time.now.day,Time.new.hour,Time.now.min,00)
    if @work.save
      flash[:success] = "退社時間を登録しました"
      redirect_to user_path
    else
      flash[:info] = "失敗しました。"
      redirect_to root_url
    end
  end
  
  def timeedit
    @user = User.find(params[:id])
  end
  
  def attendancetime_edit
    if current_user.admin?
      redirect_to :action => 'index'
    end
    @user = User.find(params[:id])
    @youbi = %w[日 月 火 水 木 金 土]
    @first_day = params[:first_day].to_datetime
    if @work.nil?
      @work = Work.new
    end
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
    # 上長ユーザを全取得
    ids = [@user.applied_last_time_user_id]
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact
    
    # 期間分のデータチェック
    (@first_day..@last_day).each do |date|
      # 該当日付のデータがないなら作成する
      if !@user.works.any? {|attendance| attendance.day == date }
        attend = Work.create(user_id: @user.id, day:date)
        attend.save
      end
    end
    
    # 表示期間の勤怠データを日付順にソートして取得
    @attendances = @user.works.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
  end
  
  def attendancetime_update
    @user = User.find(params[:id])
    
    # 各勤怠情報を更新
    params[:works].each do |id, item|
      # 申請者がない行はカット
      if item["authorizer_user_id_of_attendance"].blank?
        next
      end
      attendance = Work.find(id)
      attendance.update_attributes(item.permit(:remarks, :overtime_work, :work_description, :authorizer_user_id_of_attendance))
      
      # @note 初期値を変更前のカラムにするためparamsにはwork_start/endで渡しています
      # 　　　格納先はedited_work_start/endのため注意
      # 在社時間ーでエラー表示
      if (item["attendance_time"]).to_i > (item["leaving_time"]).to_i
        if params[:check].nil?
          flash[:danger] = '在社時間がーになっています'
          redirect_back(fallback_location: root_path) and return
        else
          # 申請者が入力されていたら『申請中』に変更する
          if !item[:authorizer_user_id_of_attendance].blank?
            attendance.applying1! 
            # 申請者の番号も保持
            @user.update_attributes(applied_last_time_user_id: item[:authorizer_user_id_of_attendance])
          end
        end
      elsif item["attendance_time"].blank? || item["leaving_time"].blank?
        # 申請者入力で出社/退社時間が空ならエラー表示
        flash[:danger] = '出社or退社時間が空になっています'
        redirect_back(fallback_location: root_path) and return
      else
        # 申請者が入力されていたら『申請中』に変更する
        if !item[:authorizer_user_id_of_attendance].blank?
          attendance.applying1! 
          # 申請者の番号も保持
          @user.update_attributes(applied_last_time_user_id: item[:authorizer_user_id_of_attendance])
        end
      end

      if !item["attendance_time"].empty?
        attendance.update_column(:edited_work_start, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, item["attendance_time"].to_i))
      end
      # 退勤があれば更新
      if !item["leaving_time"].empty?
        attendance.update_column(:edited_work_end, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, item["leaving_time"].to_i))
      end
      # チェックがあれば翌日の時間で退社扱い
      if !params[:check].nil? && !attendance.edited_work_end.nil?
        if params[:check].include?(attendance.day.to_s)
          attendance.update_column(:edited_work_end, attendance.edited_work_end+1.day)
        end
      end
    end
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
  end
  
  # 申請された勤怠編集を更新する（承認や否認する）
  def update_applied_attendance
    
    # 変更チェックが1つ以上で勤怠変更情報を更新
    if !params[:check].blank?
      @attendances = Work.where("id in (?)", params[:application_edit_state])
      params[:attendance].each do |id, item|
        # 更新チェックがなければ何もしない
        if !params[:check].include?(id)
          next
        end
        
        attendance = Work.find(id)
        if attendance.blank?
          next
        end
        
        # 申請情報更新
        attendance.update_attributes(item.permit(:application_edit_state))
        
        if attendance.approval2?
          # 現在の出勤/退勤時刻を変更前として保持 @note 変更前が空（この日付では初回の変更）なら保存
          attendance.update_attributes(before_edited_work_start: attendance.attendance_time) if attendance.before_edited_work_start.blank?
          attendance.update_attributes(before_edited_work_end: attendance.leaving_time) if attendance.before_edited_work_end.blank?
          # 承認された場合は出勤/退勤時刻を上書きする
          attendance.update_attributes(attendance_time: attendance.edited_work_start, leaving_time: attendance.edited_work_end)
        end
      end
    end
    
    @user = User.find(params[:id])
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
  end
  
  def employees_display
    @working_users = {}
    User.all.each do |user|
    if user.works.any?{|a|
       ( a.day == Date.today &&
         !a.attendance_time.blank? &&
         a.leaving_time.blank? )
        }
     @working_users[user.uid] = user.name
    end
   end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:info] = "ユーザを登録しました"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find_by(id: params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールをアップデートしました"
      redirect_to user_url
    else
      render @users
    end
  end
  
  def timeupdate
    @user = User.find_by(params[:id])
    if @user.update_attributes(time_params)
      flash[:success] = "基本時間をアップデートしました"
      redirect_to basictime_edit_path
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました"
    redirect_to users_url
  end
  
  def import
    # ファイルセットされていたら保存と結果のメッセージを取得して表示
    if !params[:file].blank?
      # 保存と結果のメッセージを取得して表示
      message = User.import(params[:file])
      flash[:notice] = message
    else
      flash[:danger] = "CSVファイルを選択してください"
    end
    redirect_to users_path
  end
  
  # 1ヵ月分の勤怠申請
  def onemonth_application
    @user = User.find_by(id: params[:one_month_attendance][:application_user_id])
    
    # 申請先が空なら何もしない
    if params[:one_month_attendance][:authorizer_user_id].blank?
      flash[:danger] = "所属長承認の申請宛先指定が空です"
      redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
      return
    end
    
    # 更新ユーザが見つからない場合はホームへ戻る
    if @user.nil?
      flash[:error] = "自分のアカウントが見つかりませんでした"
      redirect_to(root_url)
      return
    end

    @one_month_attendance = OneMonthAttendance.find_by(application_user_id: params[:one_month_attendance][:application_user_id], application_date: params[:one_month_attendance][:application_date])
    # データがないなら新規作成
    if @one_month_attendance.nil?
      @one_month_attendance = OneMonthAttendance.new(one_month_attendance_params)
      if !@one_month_attendance.save
        flash[:error] = "所属長承認の申請に失敗しました"
        redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
        return
      end
    else
      if !@one_month_attendance.update_attributes(one_month_attendance_params)
        flash[:error] = "所属長承認の申請に失敗しました"
        redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
        return
      end
    end

    @one_month_attendance.applying!
    # 申請者の番号も保持
    @user.update_attributes(applied_last_time_user_id: @one_month_attendance.authorizer_user_id)
    flash[:success] = "所属長承認申請しました"
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
  end

  private

    def user_params
      params.require(:user).permit(:id, :name, :email, :password,:affiliation,
                                   :uid, :cardID, :basictime, :workingtime, :working_time_End)
    end
    
    def time_params
      params.require(:user).permit(:workingtime,:basictime)
    end
    
    def works_params
      params.require(:work).permit(works: [:attendance_time, :leaving_time, :work_description, :authorizer_user_id_of_attendance])[:works]
    end
    
    def one_month_attendance_params
      params.require(:one_month_attendance).permit(:application_user_id, :authorizer_user_id, :application_date, :application_state)
    end
    
    def attendance_CSV_output
      csv_str = CSV.generate do |csv|
        # ユーザ情報のヘッダー
        csv << ["#{@first_day.strftime("%Y年%m月")}　時間管理表"]
        csv << ["名前", @user.name, "所属", @user.affiliation, "コード", @user.uid, "出勤日数", "#{@working_days}日"]
        # 改行
        csv << [""]
        
        # 勤怠情報のヘッダー
        csv_column_names = %w(日付 曜日 出社時間 退社時間 在社時間 備考 指示者)
        csv << csv_column_names
        @works.each do |attendance|
          # 出社時間
          !attendance.attendance_time.nil? ? attendance_time = attendance.attendance_time.strftime("%H:%M") : attendance_time = "";
          # 退社時間
          !attendance.leaving_time.nil? ? leaving_time = attendance.leaving_time.strftime("%H:%M") : leaving_time = "";
          # 在社時間
          !attendance.attendance_time.nil? && !attendance.leaving_time.nil? ? work_sum = format("%.2f", (attendance.leaving_time - attendance.attendance_time)/3600) : work_sum = "";
          
          csv_column_values = [
            attendance.day.strftime("%m/%d"),
            @youbi[attendance.day.wday],
            attendance_time,
            leaving_time,
            work_sum,
            attendance.remarks,
          ]
          csv << csv_column_values
        end
      end
      send_data(csv_str, filename: "#{@first_day.strftime("%Y年%m月")}_#{@user.name}.csv", type: :csv)
    end
    
    # beforeアクション

    # 正しいユーザーかどうか確認
    # def correct_user
    #   @user = User.find(params[:id])
    #   redirect_to(root_url) unless current_user?(@user)
    # end
    
    def show_user
      @user = User.find(params[:id])
      redirect_to(root_url) if @user != User.find_by(id: session[:user_id]) unless current_user.admin?
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def admin_or_correct_user
      @user = User.find(params[:id])
      if !current_user?(@user) && !current_user.admin?
        redirect_to(root_url)
      end
    end
    
end
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :show_user, only: [:show, :attendancetime_edit, :attendancetime_update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :timeupdate ]
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
    @user = User.new
  end
  
  def show
    @work = Work.find_by(id: params[:id])
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
    end
    @work_sum /= 3600

    # CSV出力ファイル名を指定
    respond_to do |format|
      format.html
      format.csv do
        user_attendance_CSV_output
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
    @user = User.find(params[:id])
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
  end
  
  def attendancetime_update
    @user = User.find(params[:id])
    works_params.each do |id, value|
      work=Work.find(id)
      work.update_attributes(value)
    end
    flash[:success] = "勤怠時間を編集しました"
    redirect_to user_path
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
      flash[:error] = "CSVファイルを選択してください"
    end
    redirect_to users_path
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
      params.require(:work).permit(works: [:attendance_time, :leaving_time])[:works]
    end
    
    def user_attendance_CSV_output
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
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def show_user
      @user = User.find(params[:id])
      redirect_to(root_url) if @user != User.find_by(id: session[:user_id]) unless current_user.admin?
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
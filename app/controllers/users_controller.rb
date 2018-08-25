class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :timeupdate]
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  
  def show
   if logged_in?
     @user = current_user
     @working_days = Work.where(userid: params[:id]).group(:leaving_time).count
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

  def new
    @user = User.new
  end
  
  def attend
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.attendance_time = Time.now
    if @work.save
      flash[:success] = "出社時間を登録しました"
      redirect_to root_url
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
      flash[:success] = "退社時間を登録しました"
      redirect_to root_url
    else
      render("works/edit")
    end
  end
  
  def timeedit
    @user = User.find(params[:id])
  end
  
  def attendancetime_edit
    @user = User.find(params[:id])
    @working_days = Work.where(userid: params[:id]).group(:leaving_time).count
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
    redirect_to("/users/#{@user.id}/attendancetime_edit")
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
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールをアップデートしました"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def timeupdate
    @user = User.find(params[:id])
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

  def following
    @title = "フォロー数"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "フォロワー数"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation,:belongs_to)
    end
    
    def time_params
      params.require(:user).permit(:workingtime,:basictime)
    end
    
    def works_params
      params.require(:work).permit(works: [:attendance_time, :leaving_time])[:works]
    end
    
    # beforeアクション

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
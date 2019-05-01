class BasePointsController < ApplicationController
  before_action :set_base_point, only: [:show, :edit, :update, :destroy]
  before_action :admin_user,     only: [:index, :show, :new, :edit, :create, :update, :destroy ]

  # GET /base_points
  # GET /base_points.json
  def index
    @base_point = BasePoint.new
    @base_points = BasePoint.all
  end

  # GET /base_points/1
  # GET /base_points/1.json
  def show
  end

  # GET /base_points/new
  def new
    @base_point = BasePoint.new
  end

  # GET /base_points/1/edit
  def edit
  end

  # POST /base_points
  # POST /base_points.json
  def create
    @base_point = BasePoint.new(base_point_params)
    if @base_point.save
      flash[:success] = "拠点登録完了しました"
    else
      flash[:danger] = "拠点登録に失敗しました"
    end
    redirect_to base_points_path
  end

  # PATCH/PUT /base_points/1
  # PATCH/PUT /base_points/1.json
  def update
    if @base_point.update(base_point_params)
      flash[:success] = "拠点情報編集完了しました"
    else
      flash[:danger] = "拠点情報編集失敗しました"
    end
  redirect_to base_points_path
  end

  # DELETE /base_points/1
  # DELETE /base_points/1.json
  def destroy
    if @base_point.destroy
      flash[:success] = "拠点情報削除しました"
    else
      flash[:danger] = "拠点情報削除に失敗しました"
    end
    redirect_to base_points_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_base_point
      @base_point = BasePoint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def base_point_params
      params.require(:base_point).permit(:name, :attendance_state, :number)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end

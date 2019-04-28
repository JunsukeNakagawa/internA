class BasePointsController < ApplicationController
  before_action :set_base_point, only: [:show, :edit, :update, :destroy]

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
      flash[:error] = "拠点登録に失敗しました"
    end
    redirect_to base_points_path
  end

  # PATCH/PUT /base_points/1
  # PATCH/PUT /base_points/1.json
  def update
    respond_to do |format|
      if @base_point.update(base_point_params)
        format.html { redirect_to @base_point, notice: '拠点の変更完了しました' }
        format.json { render :show, status: :ok, location: @base_point }
      else
        format.html { render :edit }
        format.json { render json: @base_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /base_points/1
  # DELETE /base_points/1.json
  def destroy
    @base_point.destroy
    respond_to do |format|
      format.html { redirect_to base_points_url, notice: '拠点の削除完了しました' }
      format.json { head :no_content }
    end
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
end

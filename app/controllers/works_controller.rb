class WorksController < ApplicationController
  
  def new
  end
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
end

class SmartListsController < ApplicationController

  def create
    logger.debug { params[:search] }
    render :null
  end
end

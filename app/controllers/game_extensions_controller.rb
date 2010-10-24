class GameExtensionsController < ApplicationController
  
  
  def index
    respond_to do |format|
      format.json do
        @games = Game.extensions.find(:all)
        render :json => @games
      end
    end
  end
  
  
  def new
    @base_game = Game.find(params[:game_id])
    @extension = @base_game.extensions.build
  end
  
  
  def create
    @extension = Game.find(params[:game][:id]) unless params[:game][:id].blank?
    @base_game = Game.find(params[:game][:base_game_id]) unless params[:game][:base_game_id].blank?
    if(@base_game && @extension)
      @extension.base_game = @base_game
      @extension.save
      respond_to do |wants|
        wants.html { redirect_to(game_path(@base_game))  }
      end
    else
      respond_to do |wants|
        wants.html do
          @extension = @base_game.extensions.build
          render :new
        end
      end
    end
  end
end

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
    @extensions = [@base_game.extensions.build, @base_game.extensions.build]
  end
  
  
  def create
    @base_game = Game.find(params[:game_id])
    ids = params[:games].values.map{|g| g["id"] }.reject{|id| id.blank?}
    exts = Game.find(ids)
    if(@base_game && exts.size > 0)
      exts.each do |ext|
        ext.update_attribute(:base_game_id, @base_game.id)
      end
      respond_to do |wants|
        wants.html { redirect_to(game_path(@base_game))  }
      end
    else
      respond_to do |wants|
        wants.html do
          @extensions = [@base_game.extensions.build, @base_game.extensions.build]
          render :new
        end
      end
    end
  end
end

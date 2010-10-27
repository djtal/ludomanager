class GameExtensionsController < ApplicationController
  subnav :games
  
  def index
    if params[:game_id]
      @base = Game.find(params[:game_id], :include => :extensions)
      @extensions = @base.extensions
    else
      @extensions = Game.extensions.find(:all)
    end
    respond_to do |format|
      format.html
      format.json do
        render :json => @extensions
      end
    end
  end
  
  def new
    @base = Game.find(params[:game_id], :include => :extensions)
    @extensions = [@base.extensions.build, @base.extensions.build, @base.extensions.build]
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
          @extensions = [@base_game.extensions.build, @base_game.extensions.build, @base_game.extensions.build]
          render :new
        end
      end
    end
  end
  
  def destroy_multiple
    @base = Game.find(params[:game_id])
    ids = params[:extensions].values.map{|ext| ext["id"] if ext["delete"] == "1"}.reject{|id| id.blank?}
    exts = Game.find(ids)
    if (exts)
      exts.each do |ext|
        ext.update_attribute :base_game_id, nil
      end
    end
    
    respond_to do |format|
      format.html { redirect_to(game_game_extensions_path(@base))  }
    end
  end
end

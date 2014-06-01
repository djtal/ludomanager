# encoding: UTF-8
class GameExtensionsController < ApplicationController
  subnav :games

  def index
    if params[:game_id]
      @base = Game.includes(:extensions).find_by_id(params[:game_id])
      @extensions = @base.extensions
    else
      @extensions = Game.extensions
    end
    respond_to do |format|
      format.html
      format.json { render json: @extensions }
    end
  end

  def new
    @base = Game.includes(:extensions).find_by_id(params[:game_id])
    @games = Game.base_games - [@base]
    @extensions = [@base.extensions.build, @base.extensions.build, @base.extensions.build]
  end

  def create
    @base = Game.find_by_id(params[:game_id])
    ids = params[:extensions][:games].values.map{|g| g["id"] }.reject{|id| id.blank?}
    exts = Game.find(ids)
    if(@base && exts.size > 0)
      exts.each do |ext|
        ext.update_attribute(:base_game_id, @base.id)
      end
      respond_to do |wants|
        wants.html { redirect_to(game_path(@base))  }
      end
    else
      respond_to do |wants|
        wants.html do
          @games = Game.all - @base.extensions - [@base]
          @extensions = [@base.extensions.build, @base.extensions.build, @base.extensions.build]
          render :new
        end
      end
    end
  end

  def destroy_multiple
    @base = Game.find_by_id(params[:game_id])
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

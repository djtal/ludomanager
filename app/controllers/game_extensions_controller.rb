class GameExtensionsController < ApplicationController
  
  def new
    @base_game = Game.find(params[:game_id])
    @extension = @base_game.extensions.build
  end
end

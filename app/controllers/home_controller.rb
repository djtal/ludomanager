class HomeController < ApplicationController
  before_filter :find_last_games


  protected
  
  def find_last_games
    @games = Game.find :all , :limit => 5
  end
end

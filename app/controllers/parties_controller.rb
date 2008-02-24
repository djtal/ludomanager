class PartiesController < ApplicationController
  before_filter :login_required
  
  def index
    @parties = current_account.parties.played_games
    @account_games = current_account.games
    @filter = :all
    @last_parties = current_account.parties.last_played
    if params[:filter] && params[:filter][:type] == "ludo"
        @account_games = current_account.games
        @parties = @parties.select{ |game, parties| @account_games.include?(game)}
        @filter = :ludo
    end
    @count = @parties.inject(0){ |acc, group| acc += group[1].size}
    @high, @medium, @low = split_parties(@parties)
    @high = @high.sort_by{ |game, parties| parties.size}.reverse
    @medium = @medium.sort_by{ |game, parties| parties.size}.reverse
    @low = @low.sort_by{ |game, parties| parties.size}.reverse
  end
  
  def create
    @game = Game.find params[:game_id]
    party = current_account.parties.build
    party.game = @game
    party.save
    @account_games = current_account.games
    @count = current_account.parties.count
    @last_parties = current_account.parties.last(5)
    @parties = Party.find(:all, :conditions => {:account_id => current_account.id, :game_id => @game.id})
    respond_to do |format|
      format.html{ redirect_to parties_path }
      format.js
    end  
  end
  
  def played
    
  end
  
  protected
  
  def split_parties(parties)
  	high, medium, low = [], [], []
  	parties.each do |group|
      if (group[1].size >= 10)
        high << group
      elsif (group[1].size >= 4)
        medium << group
      else
        low << group
      end
    end
    return high, medium, low
  end
  
  def set_section
    @section = :parties
  end
end

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
  
  #use in main view ie not in calendar
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
  
  #used for playing a game in calendar context
  # can be merged with create but how to differentiate render type taht are the same mime type
  def play
    current_account.parties.build(params[:parties].values)
    current_account.save
    @date = params[:parties]["1"][:created_at].to_date
    @parties = current_account.parties.find(:all, :conditions => ["parties.created_at >= ? AND parties.created_at <= ?", @date, @date + 1.day - 1.second])
    @account_games = current_account.games
    respond_to do |format|
      format.js
    end
  end
  
  def add_party_form
    session[:parties] += 1
    @party = Party.new(:created_at => session[:date])
    respond_to do |format|
      format.js
    end
  end
  
  def resume
    @date = Time.now
    @date = Date.new(params[:date][1].to_i, params[:date][0].to_i, -1) if params[:date].size == 2
    @date = @date.to_time
    @parties = current_account.parties.find(:all, :conditions => ["parties.created_at >= ? AND parties.created_at <= ?", @date.beginning_of_month, @date.end_of_month + 1.day - 1.second ])
    previous_played_games = current_account.parties.find(:all, 
    :conditions => ["parties.created_at < ?", @date.beginning_of_month]).map(&:game).uniq
    @days = @parties.group_by{ |p| p.created_at.mday}
    @games_count = @parties.map(&:game_id).uniq.size
    @account_games = current_account.games
    @other = (@parties.map(&:game_id) - (@account_games.map(&:id))).size
    @yours = @parties.size - @other
    @discovered = @parties.map(&:game).uniq.reject{|g| previous_played_games.include?(g)}
  end
  
  def new
    session[:parties] = 1
    @date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @party = Party.new(:created_at => @date)
    session[:date] = @date
    respond_to do |format|
      format.js
    end
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

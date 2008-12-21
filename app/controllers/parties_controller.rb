class PartiesController < ApplicationController
  before_filter :login_required
  
  def index
    parties = current_account.parties
    @count = parties.count
    @yours, @other = parties.split_mine(current_account.games)
    @parties = parties.by_game.to_a.paginate(:page => params[:page])
    #used to find last played date for each game you've played
    @last_played = current_account.parties.maximum(:created_at, :group => :game).to_hash
    @last_parties = current_account.parties.last_play(10).group_by(&:game)
  end
  
  def group
    @games = current_account.parties.count(:group => 'games.target', :include => :game)
    respond_to do |format|
      format.json do
        data = @games.inject([]){ |acc, group| acc << {:data => [[1,group[1]]], :label => Game::Target[group[0].to_i][0]}}
        render :json => data
      end
    end
  end
  
  def breakdown
    @game = Game.find(params[:game_id])
    @parties = current_account.parties.find_all_by_game_id(@game.id, :order => "created_at ASC")
    @yearly = @parties.group_by{|p| p.created_at.year}
    

    respond_to do |format|
      format.html
      format.json do
        @breakdown = @yearly.inject([]) do |acc, set|
          logger.debug { "year : #{set[0]} - parties : #{set[1].size}" }
          parties = set[1].group_by{|p| p.created_at.month}
          data = (1..12).inject([]) do |a, month|
            a << [month, (parties[month].nil? ? 0 : parties[month].size)] 
          end
          acc << {:data => data, :label => set[0]}
        end

        render :json => @breakdown
      end
    end
  end
  
  def resume
    @date = Time.now
    @date = Date.new(params[:date][1].to_i, params[:date][0].to_i, -1) if params[:date].size == 2
    @date = @date.to_time
    @parties = current_account.parties.find_by_month(@date, :include => [:game => :image])
    @count = @parties.size
    @days = @parties.group_by{ |p| p.created_at.mday}
    find_played(@parties)
    find_yours(@parties)
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
    current_account.parties.create(params[:parties].values)
    @date = params[:parties]["1"][:created_at].to_time
    @parties = current_account.parties.find_by_month(@date, :include => [:game => :image])
    @daily = @parties.select{|p| p.created_at.to_date == @date.to_date}
    find_yours(@parties)
    find_played(@parties)
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
  
  def new
    session[:parties] = 1
    @date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @party = Party.new(:created_at => @date)
    session[:date] = @date
    respond_to do |format|
      format.js
    end
  end
  
  def show
    party = current_account.parties.find(params[:id])
    @parties = current_account.parties.find_all_by_created_at(party.created_at, :include => [:game, :players], :order => "games.name ASC")
    @previous = current_account.parties.find(:first, :conditions => ["created_at < ?", party.created_at], :order => "created_at DESC")
    @next = current_account.parties.find(:first, :conditions => ["created_at > ?", party.created_at], :order => "created_at ASC")
    @members = @parties.collect{|p| p.members}.flatten.uniq
    @date = party.created_at.to_date
  end
  
  def destroy
    @party = current_account.parties.find(params[:id])
    @party.destroy
    respond_to do |format|
      format.js
    end
  end
  
  protected
  
  def find_yours(parties)
    account_games = current_account.games
    @other = (parties.map(&:game_id) - (account_games.map(&:id))).size
    @yours = parties.size - @other
  end
  
  def find_played(parties)
    @games = []
    previous_played_games = current_account.parties.find(:all, :select => :game_id,
    :conditions => ["parties.created_at < ?", @date.beginning_of_month]).map(&:game_id).uniq
    parties.map(&:game).uniq.each do |g|
      @games << [g, !previous_played_games.include?(g.id), @parties.select{ |p| p.game_id == g.id}.size ]
    end
    @games = @games.sort_by{ |set| set[2]}.reverse
  end
  
  def set_section
    @section = :parties
  end
end

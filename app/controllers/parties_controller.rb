class PartiesController < ApplicationController
  before_filter :login_required
  
  def index
    parties = current_account.parties
    @count = parties.count
    @yours, @other = parties.split_mine(current_account.games)
    @parties = parties.by_game.to_a.paginate(:page => params[:page])
    #used to find last played date for each game you've played
    @last_played = current_account.parties.maximum(:created_at, :group => :game)
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
    @parties = current_account.parties.find_all_by_game_id(@game.id, :order => "created_at ASC", :include => {:players => :member})
    @yearly = @parties.group_by{|p| p.created_at.year}

    
    respond_to do |format|
      format.html do
        # grab all player for the game
        @members = @parties.map(&:players).flatten.map(&:member).uniq
      end
      # gather data for bar graph
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
  
  def most_played
    @year = params[:year] || nil
    @most_played = current_account.parties.most_played(5, @year)
    respond_to do |format|
      format.js
    end
  end
  
  def resume
    @date = Time.now
    @date = Date.new(params[:date][1].to_i, params[:date][0].to_i, -1) if params[:date] && params[:date].size == 2
    @date = @date.to_time
    @prev_date = @date - 1.month - 1.day
    @next_date = @date + 1.month - 1.day
    @parties = current_account.parties.find_by_month(@date, :include => [:game => :image])
    @count = @parties.size
    @days = @parties.group_by{ |p| p.created_at.mday}
    #need to group by game to reduce number of line in calendar
    @days = @days.inject({}) do |acc, parties| 
      #partie is an array of all plyed parties for days
      day = parties[0]
      played = parties[1]
      acc[day] = played.group_by{|p| p.game}
      acc
    end
    find_played(@parties)
    find_yours(@parties)
  end
  
  #use in main view ie not in calendar
  def create
    current_account.parties.create(params[:parties].values)
    @date = params[:parties].values.first[:created_at].to_time
    @parties = current_account.parties.find_by_month(@date, :include => [:game => :image])
    @daily = @parties.select{|p| p.created_at.to_date == @date.to_date}.group_by(&:game)
    @count = @parties.size
    find_yours(@parties)
    find_played(@parties)
    respond_to do |format|
      format.js
    end
  end
  
  #reder new partie widget in calendar sidebar
  def new
    @date = params[:date].to_date
    @index = params[:index] || 1
    @party = Party.new(:created_at => @date)
    respond_to do |format|
      format.js
    end
  end
  
  def add_party_form
    @party = Party.new(:created_at => params[:date])
    respond_to do |format|
      format.js
    end
  end
  
  def show
    @date = params[:date] ? params[:date].to_date : Time.now.to_date
    @parties = current_account.parties.find(:all, :conditions => ["parties.created_at BETWEEN ? AND ?",@date.beginning_of_day, @date.end_of_day], 
                                            :include => [:game, :players], 
                                            :order => "games.name ASC")
    @previous = current_account.parties.find(:first, :conditions => ["created_at < ?", @date.beginning_of_day], :order => "created_at DESC")
    @next = current_account.parties.find(:first, :conditions => ["created_at > ?", @date.end_of_day], :order => "created_at ASC")
    @members = @parties.collect{|p| p.members}.flatten.uniq
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

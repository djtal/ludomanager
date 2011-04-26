class PartiesController < ApplicationController
  before_filter :login_required
  subnav :parties
  
  def index
    @date = Time.now
    @date = Date.new(params[:date][1].to_i, params[:date][0].to_i, -1) if params[:date] && params[:date].size == 2
    @date = @date.to_time
    @prev_date = @date - 1.month - 1.day
    @next_date = @date + 1.month - 1.day
    @parties = current_account.parties.by_month(@date.month, :year => @date.year)
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
    @games = compute_monthly_played(@parties, @date.beginning_of_month)
    find_yours(@parties)
  end
  
  def all
    @parties = current_account.parties.by_game(params[:start])
    #always get all played game to compute first letters
    @first_letters = current_account.parties.by_game.keys.map{ |g| g.name.first.downcase}.uniq
    @parties = @parties.to_a.paginate(:page => params[:page])
    #used to find last played date for each game you've played
    @last_played = current_account.parties.maximum(:created_at, :group => :game)
    @last_parties = current_account.parties.last_play(10).group_by(&:game)
    chart_data = current_account.partiesn.breakdown(:target)
    @chart = Gchart.new(  :type => :pie,
                            :size => '200x200', 
                            :alt => "Evolution des parties par mois",
                            :legend => chart_data.keys,
                            :data => chart_data.values,
                            :theme => :thirty7signals)
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
  
  def most_played
    @year = params[:year] || nil
    @most_played = current_account.parties.most_played(5, @year)
    respond_to do |format|
      format.js
    end
  end
  
  #use in main view ie not in calendar
  def create
    current_account.parties.create(params[:parties].values)
    @date = params[:parties].values.first[:created_at].to_time
    @parties = current_account.parties.by_month(@date.month, :year => @date.year)
    @daily = @parties.select{|p| p.created_at.to_date == @date.to_date}.group_by(&:game)
    @count = @parties.size
    find_yours(@parties)
    @games = compute_monthly_played(@parties,  @date.beginning_of_month)
    respond_to do |format|
      format.js
    end
  end
  
  def new
    @date = params[:date].to_date
    @form_id = Time.now.to_i
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
    @date = params[:date] ? Time.zone.parse(params[:date]) : Time.zone.now
    parties = current_account.parties.by_day(@date) do
      {:include => :game}
    end
    @played = {}
    Struct.new("Plays", :players, :plays)
    parties.group_by{|p| p.game}.each do |game, parties|
      @played[game] = parties.group_by {|p| p.nb_player}.inject([]) do |acc, hash|
        acc << Struct::Plays.new(hash[0], hash[1].size)
      end
    end
    @previous = current_account.parties.previous_play_date_from(@date)
    @next = current_account.parties.next_play_date_from(@date)
    @played_before  = current_account.parties.past(@date.beginning_of_month, :include => :game).group_by(&:game).keys
    @date = @date.to_date
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
  
  def compute_monthly_played(parties, beginning_of_month)
    played = current_account.parties.past(beginning_of_month, :group => :game_id).map(&:game_id)
    parties.map(&:game).uniq.sort_by{|game| game.name}.inject([]) do |acc, g|
      acc << [g, !played.include?(g.id), parties.select{ |p| p.game_id == g.id}.size ]
    end
  end
  
  def set_section
    @section = :parties
  end
end

class AccountGamesController < ApplicationController
  layout "application"
  before_filter :login_required
  
  
  # GET /account_games
  # GET /account_games.xml
  def index
    opts = {
      :include => :game,
      :order => "games.name ASC",
      :page => params[:page]
    }
    if params[:start]
      cdn = ["LOWER(games.name) LIKE ?", params[:start].downcase + "%"]
      opts.merge!({:conditions => cdn}) 
    end
    #need to know wich letter have games or not
    games = current_account.games.group_by{ |g| g.name.first.downcase}
    @first_letters = games.keys
    
    @account_games = current_account.account_games.paginate(opts)
    ["recent", "no_played", "all"].each do |var|
      eval("@#{var}=#{current_account.account_games.send(var).size}")
    end
    respond_to do |format|
      format.html # index.rhtml
      format.js
      format.csv do 
        @account_games = current_account.games.group_by(&:target)
        render :layout => false
      end  
      format.xml  { render :xml => @account_games.to_xml }
    end
  end
  
  def group
    @ac_games = current_account.games.count(:group => :target)
    respond_to do |format|
      format.json do
        data = @ac_games.inject([]){ |acc, group| acc << {:data => [[1,group[1]]], :label => Game::Target[group[0]][0]}}
        render :json => data
      end
    end
  end
  
  def all
    @ag = current_account.account_games.search(params)
    render :action => :all, :layout => "simple"
  end
  
  def missing
    @missing = Game.find(:all, :select => "id, name", :conditions => ["(id NOT IN (?))", @account_games.map(&:game_id)])
    respond_to do |format|
      format.json{ render :json => @missing.to_json(:only => [:id, :name])}
    end
  end
  
  def import
     if (params[:import][:file])
         LudoImporter.new(:account => current_account).import(params[:import][:file].read)
     end
     redirect_to account_games_path
  end
  
  def importer

  end
  
  def search
    @ag = current_account.account_games.search(params)
    respond_to do |format|
      format.html {render :action => :all, :layout => "simple"}
      format.js
    end
  end
  
  
  def new
    @account_game = current_account.account_games.build(:game_id => params[:game_id])
  end
  
  def edit
    @account_game = current_account.account_games.find(params[:id])
    @editions = Edition.find(:all, :order => "published_at ASC", :conditions => {:game_id => @account_game.game_id})
  end

  # POST /account_games
  # POST /account_games.xml
  def create
    @account_game = current_account.account_games.build(params[:account_game])
    respond_to do |format|
      if @account_game.save
        @account_games = current_account.account_games.all
        flash[:now] = "#{@account_game.game.name} ajouté avec succes a votre ludotheque"
        format.html { redirect_to account_games_url}
        format.js
        format.xml  { head :created, :location => account_games_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account_game.errors.to_xml }
      end
    end
  end
  
  def update
    @account_game = current_account.account_games.find(params[:id])
    #why this line
    params[:account_game] = params[:account_game][@account_game.id.to_s] if params[:account_game].size == 1
    respond_to do |format|
      if @account_game.update_attributes(params[:account_game])
        flash[:notice] = 'AccountGame was successfully created.'
        format.js{ render :json => @account_game}
        format.html { redirect_to account_games_url}
        format.xml  { head :created, :location => accout_games_url}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account_game.errors.to_xml }
      end
    end
  end

  # DELETE /account_games/1
  # DELETE /account_games/1.xml
  def destroy
    if params[:game_id]
      @account_game = current_account.account_games.find_by_game_id(params[:game_id])
      @context = :game
    else
      @account_game = AccountGame.find(params[:id])
      @context = :account_game
    end
    @account_game.destroy
    @account_games = current_account.account_games.all
    respond_to do |format|
      format.html { redirect_to account_games_url }
      format.js
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def set_section
    @section = :account_games
  end
end

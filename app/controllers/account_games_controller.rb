class AccountGamesController < ApplicationController
  layout "application"
  before_filter :login_required
  
  
  # GET /account_games
  # GET /account_games.xml
  def index
    @account_games = current_account.account_games.find(:all, :include => {:game => :image}, :order => "account_games.created_at DESC")
    played_games = current_account.parties.map{|p| p.game_id}.uniq
    @last_buyed = @account_games.first(5)
    @month, @other, @no_play = [], [], []
    now = Time.now
    @account_games.each do |a|
      if (a.transdate.month == now.month && a.transdate.year == now.year)
        @month << a
      end
      if !played_games.include?(a.game.id)
        @no_play << a
      else
        @other << a
      end
      @month = @month.sort_by{|a| a.game.name}
      @no_play = @no_play.sort_by{|a| a.game.name}
      @other = @other.sort_by{|a| a.game.name}
    end
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @account_games.to_xml }
    end
  end
  
  def all
    @ag = current_account.account_games.find(:all, :include => {:game => :tags}, :order => "games.name ASC")
    render :action => :all, :layout => "simple"
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
    opts = {
      :include => {:game => :tags}
    }
    @tag_list = Tag.parse(params[:search][:tags])
    criterion = {}
    if !params[:search][:player].blank?
      criterion["games.min_player <= ?"] = params[:search][:player]
      criterion["games.max_player >= ?"] = params[:search][:player]
    end
    if !params[:search][:difficulty].blank?
      criterion["games.difficulty <= ?"] = params[:search][:difficulty]
    end
    opts[:conditions]  = [criterion.keys.join(" AND "), criterion.values].flatten if !criterion.empty?
    @ag = current_account.account_games.find(:all, opts)
    if !@tag_list.empty?
      @ag = @ag.select do |ag|
         found = ag.game.tags.inject(0){|acc, tag| acc + (@tag_list.include?(tag.name) ? 1 : 0)}
         params[:search][:tags_mode] == "and" ? found == @tag_list.size : found > 0
      end
    end
    @ag  = @ag.sort_by{|a| a.game.name}
    respond_to do |format|
      format.js
      format.html {render :action => :all, :layout => "simple"}
    end
  end
  
  def new
    ag = current_account.account_games.map(&:game)
    @account_game = current_account.account_games.build
    @games = Game.find(:all, :order => "name ASC").reject{|g| ag.include?(g) }
  end
  
  def edit
    ag = current_account.account_games
    @account_game = ag.find(params[:id])
    @games = Game.find(:all, :order => "name ASC").reject{|g| ag.include?(g) }
  end

  # POST /account_games
  # POST /account_games.xml
  def create
    @account_game = current_account.account_games.build(params[:account_game])
    @account_game.price = @account_game.game.price
    logger.info @account_game.transdate
    @account_game.transdate = Time.now if @account_game.transdate.blank?
    
    respond_to do |format|
      if @account_game.save
        flash[:notice] = 'AccountGame was successfully created.'
        format.html { redirect_to account_games_url}
        format.xml  { head :created, :location => account_games_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account_game.errors.to_xml }
      end
    end
  end
  
  def update
    @account_game = AccountGame.find(params[:id])
    respond_to do |format|
      if @account_game.update_attributes(params[:account_game])
        flash[:notice] = 'AccountGame was successfully created.'
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
    @account_game = AccountGame.find(params[:id])
    @account_game.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to account_games_url }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def set_section
    @section = :account_games
  end
end

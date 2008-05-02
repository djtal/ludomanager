class AccountGamesController < ApplicationController
  layout "application"
  before_filter :login_required
  
  
  # GET /account_games
  # GET /account_games.xml
  def index
    @account_games = current_account.account_games.find(:all, :include => {:game => :image}, :order => "games.name ASC")
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @account_games.to_xml }
    end
  end
  
  def all
    @ag = current_account.account_games.find(:all, :include => {:game => :tags}, :order => "games.name ASC")
    render :action => :all, :layout => "simple"
  end
  
  def missing
    account_game = current_account.account_games.find(:all, :select => :game_id)
    @missing = Game.find(:all, :select => "id, name", :conditions => ["(id NOT IN (?))", account_game.map(&:game_id)])
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

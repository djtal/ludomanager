class AccountGamesController < ApplicationController
  layout "application"
  before_filter :login_required
  subnav :account_games
  
  # GET /account_games
  # GET /account_games.xml
  def index
    respond_to do |format|
      format.html do
        find_opts = {
          :include => :game,
          :page => params[:page]
        }
        if params[:time]
          find_opts[:conditions] = {:games => {:time_category => params[:time]}}
        end  
        if params[:target]
          find_opts[:conditions]  = {:games => {:target => params[:target]}}
        end

        @mode = if params[:mode]
          params[:mode].to_sym 
        else
          :view
        end

        @account_games = if params[:start]
          current_account.account_games.start(params[:start])
        else
          current_account.account_games
        end.paginate(find_opts)

        #order base game no extension aplha
        base_games, extensions = @account_games.partition{|ac_game| ac_game.game.base_game_id.blank?}
        @order_account_games = base_games.sort_by{|ac_game| ac_game.game.name}.inject([]) do |acc, ac_game|
          exts = extensions.select{|ext| ext.game.base_game_id == ac_game.game_id}
          acc << ac_game
          acc << exts unless exts.empty?
          acc
        end.flatten
        #need to know wich letter have games or not
        @first_letters = current_account.games.first_letters
        ["recent", "no_played", "all"].each do |var|
          eval("@#{var}=#{current_account.account_games.send(var).count}")
        end
        @exts_count = current_account.games.extensions.count
        chart_data = current_account.account_games.breakdown(:target)
        @chart = Gchart.new(:type => :pie,
                                :size => '220x220', 
                                :alt => "Evolution des parties par mois",
                                :legend => chart_data.keys,
                                :legend_position => "bottom",
                                :data => chart_data.values,
                                :theme => :ludomanager)
      end
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
    @search = ACGameSearch.new(current_account, params[:search])
    @ag = @search.prepare_search.all(:include => {:game => :tags})
    render :action => :all, :layout => "simple"
  end
  
  def missing
    @missing = Game.find(:all, :select => "id, name", :conditions => ["(id NOT IN (?))", @account_games.map(&:game_id)])
    respond_to do |format|
      format.json{ render :json => @missing.to_json(:only => [:id, :name])}
    end
  end
  
  
  def search
    @search = ACGameSearch.new(current_account, params[:search])
    @ag = @search.prepare_search.all(:include => {:game => :tags}).uniq
    respond_to do |format|
      format.html {render :action => :all, :layout => "simple"}
      format.js
    end
  end
  
  
  def new
    @new_games = []
    4.times{ @new_games << current_account.account_games.build }
  end
  
  def edit
    @account_game = current_account.account_games.find(params[:id])
    @editions = Edition.find(:all, :order => "published_at ASC", :conditions => {:game_id => @account_game.game_id})
  end

  # POST /account_games
  # POST /account_games.xml
  def create
    acc_games = params[:account_game].values.select{ |games| games["game_id"] != ""}
    @new_games = current_account.account_games.create(acc_games)
    respond_to do |format|
      if @new_games.inject(true){|acc, record| acc = acc && !record.new_record? }
        @account_games = current_account.account_games.all
        flash[:now] = "#{@new_games.count} jeux ont été ajoutés a votre ludotheque"
        format.html { redirect_to account_games_url}
        format.js do
          @account_game = @new_games.first
        end
        format.xml  { head :created, :location => account_games_url }
      else
        format.html  do
          render :action => "new" 
        end
        format.xml  { render :xml => @account_game.errors.to_xml }
      end
    end
  end
  
  def update
    @account_game = current_acc ount.account_games.find(params[:id])
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

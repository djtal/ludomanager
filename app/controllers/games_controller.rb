class GamesController < ApplicationController  
  before_filter :login_required, :only => [:destroy]
  before_filter :set_section
  
  # GET /games
  # GET /games.xml
  def index
    @account_games = current_account.games if current_account
    respond_to do |format|
      format.html {@games = Game.paginate :page => params[:page], :order => 'games.name ASC', :include => [:tags, :image]}
      format.json{ render :json => Game.find(:all).to_json(:only => [:id, :name])}
    end
  end
  
  def tags
    @games = Game.search(params[:tag], :tags)
    @pager = ::Paginator.new(@games.size, 10) do |offset, per_page|
      @games[offset, per_page]
    end
    @page = @pager.page(params[:page])
    @games = @page.items
    render :action => "index"
  end

  def search
    @games = Game.search(params[:search], params[:page])
    render :action => :index
  end


  # GET /games/1
  # GET /games/1.xml
  def show
    @game = Game.find(params[:id], :include => [:tags, :image])
    @title = @game.name
    respond_to do |format|
      format.html # show.rhtml
      format.js
      format.xml  { render :xml => @game.to_xml }
    end
  end

  # GET /games/new
  def new
    @game = Game.new
    @authors = []
    3.times{@authors << Author.new}
  end

  # GET /games/1;edit
  def edit
    @game = Game.find(params[:id])
    if !@game.authors
      @authors = []
      3.times{@authors << Author.new}
    else
      @authors = @game.authors.find(:all)
      (3 - @authors.size).times{@authors << Author.new }
    end
  end

  # POST /games
  # POST /games.xml
  def create
    @game = Game.new(params[:game])
    respond_to do |format|
      if @game.save
        @game.tag_with params[:tag][:tag_list] if params[:tag] && params[:tag][:tag_list]
        flash[:notice] = 'Game was successfully created.'
        save_box_thumbnail!
        add_game_authors!
        format.html { redirect_to game_path(@game) }
        format.xml  { head :created, :location => game_path(@game) }
      else
        format.html do
          @authors = []
          3.times{@authors << Author.new}
          render :action => "new"
        end
        format.xml  { render :xml => @game.errors.to_xml }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.xml
  def update
    @game = Game.find(params[:id])
    respond_to do |format|
      if @game.update_attributes(params[:game])
        @game.tag_with params[:tag][:tag_list] if params[:tag] && params[:tag][:tag_list]
        flash[:notice] = 'Game was successfully updated.'
        save_box_thumbnail!
        add_game_authors!
        format.html { redirect_to game_path(@game) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game.errors.to_xml }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.xml
  def destroy
    @game = Game.find(params[:id])
    if @game.destroy
	    respond_to do |format|
	      format.html { redirect_to games_path }
	      format.xml  { head :ok }
    	end
	else
		respond_to do |format|
	      format.html do
	      	 flash[:notice] = "Vous ne pouvez pas effacez un jeu deja joué"
	      	 redirect_to games_path 
      	  end
	      format.xml  { head :ok }
    	end
		
	end
  end
  
  protected
  
  
  def set_section
  	@section = :games
  end
  
  def add_game_authors!
    if params[:authors]
      @game.authorships.delete_all
      params[:authors].each do |key, value|
        a = Author.find_or_create_from_str(value[:display_name])
        @game.authors << a if a && !@game.authors.include?(a)
      end
    end
  end
  
  def save_box_thumbnail!
    if params[:game_photo]
      @game.image.destroy if params[:game_photo][:delete] && params[:game_photo][:delete] == 1
      unless params[:game_photo][:uploaded_data].blank?
        @game.image.destroy if @game.image
        box = GamePhoto.create params[:game_photo]
        @game.image = box
      end
    end
  end
end

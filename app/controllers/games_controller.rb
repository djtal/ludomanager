class GamesController < ApplicationController  
  before_filter :login_required, :only => [:destroy]
  before_filter :set_section
  before_filter :set_basic_stats, :only => [:index, :tags]
  
  # GET /games
  # GET /games.xml
  def index
    if params[:tag_id]
      @game_all = Game.search(params[:tag_id], :tags)
      @mod = :tag
    else
      @mod = :all
      @game_all = Game.find(:all, :include => [:image, :tags], :order => "games.name ASC")
    end
    @title = "Les jeux"
    @pager = ::Paginator.new(@game_all.size, 10) do |offset, per_page|
       @game_all[offset, per_page]
     end
    
    @page = @pager.page(params[:page])
    @games = @page.items

    respond_to do |format|
      format.html
      format.xml  { render :xml => @games.to_xml }
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
    search_type = params[:search][:type].to_sym || :title
    @games = Game.search(params[:search][:q], search_type)
    respond_to do |format|
      format.html do
        @pager = ::Paginator.new(@games.size, 10) do |offset, per_page|
          @games[offset, per_page]
        end
        @page = @pager.page(params[:page])
        @games = @page.items
        if (@games.size == 1)
          redirect_to :action => "show", :id => @games.first
        else
          render :action => "index"
        end
      end
      format.js
      format.xml  { render :xml => @games.to_xml }
    end
  end
  
  def play
    @games = Game.search(params[:party][:q])
    respond_to do |format|
      format.js
    end
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
    @game.tag_with params[:tag] if params[:tag]
    respond_to do |format|
      if @game.save
        add_game_authors! if params[:authors]["1"]
        flash[:notice] = 'Game was successfully created.'
        save_box_thumbnail!
        format.html { redirect_to game_path(@game) }
        format.xml  { head :created, :location => game_path(@game) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @game.errors.to_xml }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.xml
  def update
    @game = Game.find(params[:id])
    @game.tag_with params[:tag] if params[:tag]
    respond_to do |format|
      if @game.update_attributes(params[:game])
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
  
  def set_basic_stats
  	@total_games = Game.count
    @total_parties = Party.count
  end
  
  def set_section
  	@section = :games
  end
  
  def add_game_authors!
    @game.authors.destroy_all
    params[:authors].each do |key, value|
      a = Author.find_or_create_from_str(value[:display_name])
      @game.authors << a if a && !@game.authors.include?(a)
    end
  end
  
  def save_box_thumbnail!
    @game.image.destroy if params[:delete_image]
    unless params[:game_photo][:uploaded_data].blank?
      @game.image.destroy if @game.image
      box = GamePhoto.create! params[:game_photo]
      @game.image =  box
      @game.save
    end
  end
end

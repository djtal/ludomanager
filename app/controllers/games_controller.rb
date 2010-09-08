class GamesController < ApplicationController  
  before_filter :login_required, :except => [:index, :show, :search]
  subnav :games
  
  # GET /games
  # GET /games.xml
  def index
    respond_to do |format|
      format.html do 
        @last = Game.find(:all, :order => "created_at DESC", :limit => 10)
        @games = if (params[:start])
          Game.start(params[:start]).paginate(:page => params[:page],
                                    :per_page => 15,  :include => [:tags,:editions])
        else
          Game.paginate(:page => params[:page], :per_page => 15, :order => 'games.name ASC', 
                  :include => [:tags,:editions])
        end
        @first_letters = Game.find(:all, :select => :name).map{|a| a.name.first.downcase}.uniq
      end
      format.json do
        opts = {}
        opts[:conditions] = {:base_game_id => ""} if params[:base_game]
        @games =  Game.find(:all)
        render :json => @games.to_json(:only => [:id, :name])
      end
    end
  end
  
  def search
    @games = Game.search(params[:search], params[:page])
    @last = Game.find(:all, :order => "created_at DESC", :limit => 10)
    render :action => :index
  end


  # GET /games/1
  # GET /games/1.xml
  def show
    @game = Game.find(params[:id], :include => [:tags, :authors, :extensions, :base_game])
    @editions = @game.editions.all(:order => "published_at ASC", :include => :editor)
    @title = @game.name
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @game.to_xml }
    end
  end

  # GET /games/new
  def new
    @game = Game.new
    @authorships = []
    3.times{@authorships << @game.authorships.new}
  end

  # GET /games/1;edit
  def edit
    @game = Game.find(params[:id])
    @authorships = @game.authorships
    @authorships << @game.authorships.new if @authorships.size == 0
  end
  
  def replace
    @game = Game.find(params[:id])
  end
  
  
  def merge
    @source = Game.find(params[:id])
    @destination = Game.find(params[:replace][:destination_id]) if params[:replace][:destination_id] != ""
    if (@source && @destination)
      AccountGame.replace_game(@source, @destination)
      Party.replace_game(@source, @destination)
      @source.destroy
      return redirect_to(game_path(@destination))
    end
    redirect_to game_path(@source)
  end

  # POST /games
  # POST /games.xml
  def create
    @game = Game.new(params[:game])
    respond_to do |format|
      if @game.save
        @game.tag_with params[:tag][:tag_list] if params[:tag] && params[:tag][:tag_list]
        flash[:notice] = 'Game was successfully created.'
        @game.authorships.create_from_names(params[:authorship])
        format.html { redirect_to game_path(@game) }
        format.xml  { head :created, :location => game_path(@game) }
      else
        format.html do
          @authorships = []
          3.times{@authorships << Authorship.new}
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
        @game.authorships.create_from_names(params[:authorship])
        format.html { redirect_to game_path(@game) }
        format.xml  { head :ok }
      else
        if !@game.authors
          @authors = []
          3.times{@authors << Author.new}
        else
          @authors = @game.authors.find(:all)
          (3 - @authors.size).times{@authors << Author.new }
        end
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
	      format.js
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
  
end

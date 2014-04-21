# encoding: UTF-8
class GamesController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :search]
  subnav :games

  def index
    respond_to do |format|
      format.html do
        @last = Game.find(:all, order: 'created_at DESC', limit: 10)
        @games = if (params[:start])
          Game.start(params[:start]).paginate(page: params[:page],
                                    per_page: 15,  include: [:tags,:editions])
        else
          Game.paginate(page: params[:page], per_page: 15, order: 'games.name ASC',
                  include: [:tags,:editions])
        end
        @first_letters = Game.first_letters
      end
      format.json do
        opts = {}
        opts[:conditions] = { base_game_id: "" } if params[:base_game]
        @games =  Game.find(:all)
        render json: @games.to_json( only: [:id, :name])
      end
    end
  end

  def search
    @games = Game.search(params[:search], params[:page])
    @last = Game.find(:all, order: 'created_at DESC', limit: 10 )
    render action: :index
  end

  def show
    @game = Game.find(params[:id], include: [:tags, :authors, :extensions, :base_game])
    @editions = @game.editions.all(order: 'published_at ASC', include: :editor)
    @title = @game.name
  end

  def new
    @game = Game.new
    @base_games = Game.base_games.find(:all)
    @authorships = []
    3.times{@authorships << @game.authorships.new}
  end

  def edit
    @game = Game.find(params[:id], include: :base_game)
    @base_games = Game.base_games.find(:all)
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

  def create
    @game = Game.new(params[:game])
    respond_to do |format|
      if @game.save
        @game.tag_with params[:tag][:tag_list] if params[:tag] && params[:tag][:tag_list] != ""
        flash[:notice] = 'Game was successfully created.'
        @game.authorships.create_from_names(params[:authorship])
        format.html { redirect_to game_path(@game) }
      else
        format.html do
          @base_games = Game.base_games.find(:all)
          @authorships = []
          3.times{@authorships << Authorship.new}
          render action: :new
        end
      end
    end
  end

  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        @game.tag_with params[:tag][:tag_list] if params[:tag] && params[:tag][:tag_list] != ""
        flash[:notice] = 'Game was successfully updated.'
        @game.authorships.create_from_names(params[:authorship])
        format.html { redirect_to game_path(@game) }
      else
        @base_games = Game.base_games.find(:all)
        if !@game.authors
          @authors = []
          3.times{@authors << Author.new}
        else
          @authors = @game.authors.find(:all)
          (3 - @authors.size).times{@authors << Author.new }
        end
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @game = Game.find(params[:id])
    if @game.destroy
      respond_to do |format|
        format.html { redirect_to games_path }
        format.js
      end
    else
      respond_to do |format|
        format.html do
          flash[:notice] = "Vous ne pouvez pas effacez un jeu deja joué"
          redirect_to games_path
        end
      end
    end
  end

  protected

  def set_section
  	@section = :games
  end

end

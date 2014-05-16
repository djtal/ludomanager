# encoding: UTF-8
class GamesController < ApplicationController
  before_filter :set_latest, only: %i(index search)
  before_filter :login_required, :except => [:index, :show, :search]
  subnav :games

  def index
    respond_to do |format|
      @games = Game
      format.html do
        @last = Game.latest(10)
        @games = @games.start(params[:start]) if (params[:start])
        @games = @games.includes(:tags, :editions).order('games.name asc')
        @games = @games.paginate(page: params[:page], per_page: 15)
        @first_letters = Game.first_letters
      end
      format.json do
        @games = @games.where(base_game_id: "") if params[:base_game]
        render json: @games.to_json( only: [:id, :name])
      end
    end
  end

  def search
    @games = Game.search(params[:search], params[:page])
    render action: :index
  end

  def show
    @game = Game.find_by_id(params[:id]).includes(:tags, :authors, :extensions, :base_game)
    @editions = @game.editions.includes(:editors).order(:published_at)
    @title = @game.name
  end

  def new
    @game = Game.new
    @base_games = Game.base_games.find(:all)
    @authorships = []
    3.times{ @authorships << @game.authorships.new }
  end

  def edit
    @game = Game.find_by_id(params[:id]).includes(:base_game)
    @base_games = Game.base_games
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
          @base_games = Game.base_games
          @authorships = []
          3.times{@authorships << Authorship.new}
          render action: :new
        end
      end
    end
  end

  def update
    @game = Game.find_by_id(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        @game.tag_with params[:tag][:tag_list] if params[:tag] && params[:tag][:tag_list] != ""
        flash[:notice] = 'Game was successfully updated.'
        @game.authorships.create_from_names(params[:authorship])
        format.html { redirect_to @game }
      else
        @base_games = Game.base_games
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
    @game = Game.find_by_id(params[:id])
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

  def set_latest
    @lest = Game.latest(10)
  end

  def set_section
  	@section = :games
  end

end

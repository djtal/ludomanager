# encoding: UTF-8
class EditionsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  subnav :games

  def index
    if params[:game_id]
      @game = Game.find(params[:game_id])
      @editions = @game.editions.includes(:editor).paginate(page: params[:page])
    else
      @editions = Edition.includes(:game, :editor).order('games.name asc').paginate(page: params[:page])
      @last = Edition.includes(:game, :editor).latest(10)
    end
  end

  def show
    @edition = Edition.find_by_id(params[:id])
  end

  def new
    @game = Game.find(params[:game_id])
    @edition = Edition.new
    @editors = Editor.order(:name)
  end

  def edit
    @game = Game.find_by_id(params[:game_id])
    @edition = @game.editions.find_by_id(params[:id])
    @editors = Editor.order(:name)
  end

  def create
    @game = Game.find_by_id(params[:game_id])
    @edition = @game.editions.build(edition_params)
    if @edition.save
      redirect_to @game, notice: "L'edition a été ajouter a #{@game.name}"
    else
      @editors = Editor.all(order: 'name ASC')
      render action: :new
    end
  end

  def update
    @game = Game.find_by_id(params[:game_id])
    @edition = @game.editions.find_by_id(params[:id])

    if @edition.update_attributes(edition_params)
      redirect_to @game, notice: "Edition mise a jour avec succes"
    else
      render action: :edit
    end
  end

  def destroy
    @game = Game.find_by_id(params[:game_id])
    @edition = @game.editions.find_by_id(params[:id])
    @edition.destroy

    respond_to do |format|
      format.html { redirect_to @game }
      format.js
    end
  end


  protected

  def edition_params
    params.require(:edition).permit(:editor_id, :name, :lang, :published_at)
  end
end

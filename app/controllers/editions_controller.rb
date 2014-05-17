# encoding: UTF-8
class EditionsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  subnav :games

  def index
    if params[:game_id]
      @game = Game.find(params[:game_id])
      @editions = @game.editions.paginate(:all, page: params[:page], include: :editor)
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
    @editors = Editor.all(order: 'name ASC')
    @edition = Edition.new
  end

  def edit
    @game = Game.find(params[:game_id])
    @editors = Editor.all(order: 'name ASC')
    @edition = Edition.find(params[:id])
  end

  def create
    @game = Game.find(params[:game_id])
    @edition = @game.editions.build(params[:edition])
    if @edition.save
      flash[:notice] = 'Edition was successfully created.'
      redirect_to game_editions_path(@game)
    else
      @editors = Editor.all(order: 'name ASC')
      render action: :new
    end
  end

  def update
    @game = Game.find_by_id(params[:game_id])
    @edition = Edition.find_by_id(params[:id])

    if @edition.update_attributes(params[:edition])
      flash[:notice] = 'Edition was successfully updated.'
      redirect_to game_editions_path(@game)
    else
      render action: :edit
    end
  end

  def destroy
    @edition = Edition.find(params[:id])
    @edition.destroy

    respond_to do |format|
      format.html { redirect_to game_editions_path(@edition.game)  }
      format.js
    end
  end
end

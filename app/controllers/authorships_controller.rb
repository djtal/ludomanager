# encoding: UTF-8
class AuthorshipsController < ApplicationController
  subnav :games

  def index
    if params[:game_id]
      @base = Game.find(params[:game_id])
      @authorships = @base.authorships.find(:all, include: :author)
    else
      @authorships = Authorship.find(:all)
    end
  end

  def show
    @authorship = Authorship.find(params[:id])
  end

  def new
    @index = params[:index].to_i || 0
    @index += 1
    @game = Game.find(params[:game_id])
    @authorship = @game.authorships.new
  end

  #used when adding via AJAX new athorship form fragment
  def new_partial_form
    @index = params[:index].to_i || 0
    @index += 1
    @authorship = Authorship.new
  end

  def edit
    @game = Game.find(params[:game_id], include: :authorships)
    @authorships = @game.authorships
    @authorships << @game.authorships.new if @authorships.size == 0
  end

  def create
    @game = Game.find(params[:game_id])
    @game.authorships.create_from_names(params[:authorship])
    flash[:notice] = 'Les autheurs sont enregistres'
    redirect_to game_path(@game)
  end

  def update
    @authorship = Authorship.find(params[:id])

    if @authorship.update_attributes(params[:authorship])
      flash[:notice] = 'Authorship was successfully updated.'
      redirect_to authorship_url(@authorship)
    else
      render action: :edit
    end
  end

  def destroy
    @authorship = Authorship.find(params[:id])
    @authorship.destroy

    redirect_to authorships_url
  end
end

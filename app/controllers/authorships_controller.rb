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


    respond_to do |format|
      format.html
    end
  end

  # GET /authorships/1
  # GET /authorships/1.xml
  def show
    @authorship = Authorship.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render xml: @authorship.to_xml }
    end
  end

  # GET /authorships/new
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

  # GET /authorships/1;edit
  def edit
    @game = Game.find(params[:game_id], include: :authorships)
    @authorships = @game.authorships
    @authorships << @game.authorships.new if @authorships.size == 0
  end

  # POST /authorships
  # POST /authorships.xml
  def create
    @game = Game.find(params[:game_id])
    @game.authorships.create_from_names(params[:authorship])
    respond_to do |format|
        flash[:notice] = 'Les autheurs sont enregistres'
        format.html { redirect_to game_path(@game) }
        format.xml  { head :created, location: authorship_url(@authorship) }
    end
  end

  # PUT /authorships/1
  # PUT /authorships/1.xml
  def update
    @authorship = Authorship.find(params[:id])

    respond_to do |format|
      if @authorship.update_attributes(params[:authorship])
        flash[:notice] = 'Authorship was successfully updated.'
        format.html { redirect_to authorship_url(@authorship) }
        format.xml  { head :ok }
      else
        format.html { render action: edit }
        format.xml  { render xml: @authorship.errors.to_xml }
      end
    end
  end

  # DELETE /authorships/1
  # DELETE /authorships/1.xml
  def destroy
    @authorship = Authorship.find(params[:id])
    @authorship.destroy

    respond_to do |format|
      format.html { redirect_to authorships_url }
      format.xml  { head :ok }
    end
  end
end

# encoding: UTF-8
class EditionsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  subnav :games


  # GET /editions
  # GET /editions.xml
  def index
    if params[:game_id]
      @game = Game.find(params[:game_id])
      @editions = @game.editions.paginate(:all, page: params[:page], include: :editor)
    else
      @editions = Edition.paginate( :all,
                                    include: [:game, :editor], order => 'games.name asc',
                                    page: params[:page])
      @last = Edition.find(:all, include: [:game, :editor], limit: 10, order: 'created_at DESC')
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render xml: @editions }
      end
    end

  end

  # GET /editions/1
  # GET /editions/1.xml
  def show
    @edition = Edition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @edition }
    end
  end

  # GET /editions/new
  # GET /editions/new.xml
  def new
    @game = Game.find(params[:game_id])
    @editors = Editor.all(order: 'name ASC')
    @edition = Edition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @edition }
    end
  end

  # GET /editions/1/edit
  def edit
    @game = Game.find(params[:game_id])
    @editors = Editor.all(order: 'name ASC')
    @edition = Edition.find(params[:id])
  end

  # POST /editions
  # POST /editions.xml
  def create
    @game = Game.find(params[:game_id])
    @edition = @game.editions.build(params[:edition])
    respond_to do |format|
      if @edition.save
        flash[:notice] = 'Edition was successfully created.'
        format.html { redirect_to game_editions_path(@game) }
        format.xml  { render xml: @edition, status: :created, location: @edition }
      else
        format.html do
          @editors = Editor.all(order: 'name ASC')
          render action: :new
        end
        format.xml  { render xml: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /editions/1
  # PUT /editions/1.xml
  def update
    @game = Game.find(params[:game_id])
    @edition = Edition.find(params[:id])

    respond_to do |format|
      if @edition.update_attributes(params[:edition])
        flash[:notice] = 'Edition was successfully updated.'
        format.html { redirect_to game_editions_path(@game) }
        format.xml  { head :ok }
      else
        format.html { render action: :edit }
        format.xml  { render xml: @edition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /editions/1
  # DELETE /editions/1.xml
  def destroy
    @edition = Edition.find(params[:id])
    @edition.destroy

    respond_to do |format|
      format.html { rredirect_to game_editions_path(@edition.game)  }
      format.js
      format.xml  { head :ok }
    end
  end
end

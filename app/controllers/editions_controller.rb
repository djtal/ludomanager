class EditionsController < ApplicationController
  # GET /editions
  # GET /editions.xml
  def index
    @editions = Edition.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @editions }
    end
  end

  # GET /editions/1
  # GET /editions/1.xml
  def show
    @edition = Edition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @edition }
    end
  end

  # GET /editions/new
  # GET /editions/new.xml
  def new
    @game = Game.find(params[:game_id])
    @editors = Editor.all(:order => "name ASC")
    @edition = Edition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @edition }
    end
  end

  # GET /editions/1/edit
  def edit
    @game = Game.find(params[:game_id])
    @editors = Editor.all(:order => "name ASC")
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
        format.html { redirect_to(@game) }
        format.xml  { render :xml => @edition, :status => :created, :location => @edition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @edition.errors, :status => :unprocessable_entity }
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
        format.html { redirect_to(@game) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /editions/1
  # DELETE /editions/1.xml
  def destroy
    @edition = Edition.find(params[:id])
    @edition.destroy

    respond_to do |format|
      format.html { redirect_to(editions_url) }
      format.js
      format.xml  { head :ok }
    end
  end
end

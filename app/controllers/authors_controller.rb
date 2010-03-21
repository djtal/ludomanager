class AuthorsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  subnav :authors
  
  # GET /authors
  # GET /authors.xml
  def index
    opts = {
      :page => params[:page],
      :include => :authorships
    }
    @first_letters = Author.find(:all, :select => :name).map{|a| a.name.first.downcase}.uniq
    respond_to do |format|
      format.html do
        @authors = if params[:start]
          Author.start(params[:start]).paginate(opts)
        else
          Author.paginate(opts)
        end
      end
      format.json do
          @authors = Author.find(:all, :order => "surname ASC")
          render :json => @authors.map{|a| a.display_name}.to_json
      end
      format.xml  { render :xml => @authors.to_xml }
    end
  end

  # GET /authors/1
  # GET /authors/1.xml
  def show
    @author = Author.find(params[:id])
    @games = @author.games.find(:all, :include => :editions, :order => "editions.created_at ASC")
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @author.to_xml }
    end
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1;edit
  def edit
    @author = Author.find(params[:id])
  end

  # POST /authors
  # POST /authors.xml
  def create
    @author = Author.new(params[:author])
    respond_to do |format|
      if @author.save
        format.html { redirect_to author_url(@author) }
        format.xml  { head :created, :location => author_url(@author) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @author.errors.to_xml }
      end
    end
  end

  # PUT /authors/1
  # PUT /authors/1.xml
  def update
    @author = Author.find(params[:id])

    respond_to do |format|
      if @author.update_attributes(params[:author])
        flash[:notice] = 'Author was successfully updated.'
        format.html { redirect_to author_url(@author) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @author.errors.to_xml }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.xml
  def destroy
    @author = Author.find(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to authors_url }
      format.js
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def set_section
    @section = :authors
  end
end

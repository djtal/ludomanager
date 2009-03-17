class EditorsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :search]
  
  # GET /editors
  # GET /editors.xml
  def index
    @editors = Editor.paginate(:all, :page => params[:page],
                                :order => "editors.name ASC",
                                :include => :editions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @editors }
    end
  end

  def search
    @editors = Editor.paginate( :page => params[:page], 
                                :conditions => ["LOWER(name) LIKE ?","%#{params[:search].downcase}%"],
                                :order => "name ASC")
    render :action => :index
  end

  # GET /editors/1
  # GET /editors/1.xml
  def show
    @editor = Editor.find(params[:id], :include => [:editions])
    editions = @editor.editions.find(:all,  :order => "published_at DESC", :include => {:game => [:image, :editors]})
    yearly = editions.reject{|ed| ed.published_at.nil?}
    blank = editions.select{|ed| ed.published_at.nil?}
    @editions = yearly.group_by{|e| e.published_at.year}
    @editions["blank"] = blank if blank.size > 0
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @editor }
    end
  end

  # GET /editors/new
  # GET /editors/new.xml
  def new
    @editor = Editor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @editor }
    end
  end

  # GET /editors/1/edit
  def edit
    @editor = Editor.find(params[:id])
  end

  # POST /editors
  # POST /editors.xml
  def create
    @editor = Editor.new(params[:editor])

    respond_to do |format|
      if @editor.save
        create_logo!
        flash[:notice] = 'Editor was successfully created.'
        format.html { redirect_to(@editor) }
        format.xml  { render :xml => @editor, :status => :created, :location => @editor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @editor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /editors/1
  # PUT /editors/1.xml
  def update
    @editor = Editor.find(params[:id])

    respond_to do |format|
      if @editor.update_attributes(params[:editor])
        create_logo!
        flash[:notice] = 'Editor was successfully updated.'
        format.html { redirect_to(@editor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @editor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /editors/1
  # DELETE /editors/1.xml
  def destroy
    @editor = Editor.find(params[:id])
    @editor.destroy

    respond_to do |format|
      format.html { redirect_to(editors_url) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  def set_section
  	@section = :editors
  end

  protected
  
  def create_logo!
    if params[:logo]
      @editor.logo.destroy if params[:logo][:delete] && params[:logo].delete(:delete) == "1"
      unless params[:logo][:uploaded_data].blank?
        @editor.logo.destroy if @editor.logo
        box = Asset.create params[:logo]
        @editor.logo = box
      end
    end
  end
end

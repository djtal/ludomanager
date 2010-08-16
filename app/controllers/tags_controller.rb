class TagsController < ApplicationController
  subnav :games
  
  def index
    respond_to do |format|
      format.html do
        @cloud = Tagging.count(:id, :group => :tag, :order => "count_id DESC",
                                :conditions => ["taggings.taggable_type = ?",     Game.acts_as_taggable_options[:taggable_type]])
        @first_letters = @cloud.keys{|tag| tag.name.first.downcase}
        @cloud = @cloud.to_a.paginate(:page => params[:page])
        
      end
      
      format.text do
        if params[:game_id]
          tags = Game.find(params[:game_id]).tag_list
        end
        render :text => tags
      end
    end
  end
  
  def lookup
    @tags = Tag.find(:all)
    respond_to do |format|
      format.json{render :json => @tags.map{|t|  t.name}.to_json}
    end
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    if (@tag)
      ids = @tag.taggings.find_all_by_taggable_type(Game.acts_as_taggable_options[:taggable_type], 
                                                      :select => :taggable_id).map(&:taggable_id)
      @games = Game.paginate(:page => params[:page], :conditions => {:id => ids}, :order => "name ASC")
    else
      @games = []
      @tag = Tag.new(:name => params[:id])
    end
  end
  
  
  def create
    @game = Game.find(params[:game_id])
    @game.tag_with(params[:value])
    render :partial => "tag_list"
  end
  
  def edit
    @tag = Tag.find_by_name(params[:id])
  end
  
  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      redirect_to tags_path
    else
      render :action => :edit
    end
  end

  def destroy
    @tag = Tag.find_by_name(params[:id])
    if @tag.destroy
      respond_to do |format|
        format.js
        format.html {redirect_to tags_path}
      end
    end
  end

end

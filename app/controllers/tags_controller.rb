class TagsController < ApplicationController
  def index
    @cloud = Tagging.count(:id, :group => :tag, :order => "count_id DESC",
                            :conditions => ["taggings.taggable_type = ?", Game.acts_as_taggable_options[:taggable_type]])
    @cloud = @cloud.to_a.paginate(:page => params[:page])
  end
  
  def lookup
    @tags = Tag.find(:all)
    respond_to do |format|
      format.json{render :json => @tags.map{|t|  t.name}.to_json}
    end
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    ids = @tag.taggings.find_all_by_taggable_type(Game.acts_as_taggable_options[:taggable_type], 
                                                    :select => :taggable_id).map(&:taggable_id)
    @games = Game.find(:all, :conditions => {:id => ids})
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

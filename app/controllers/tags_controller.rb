class TagsController < ApplicationController
  def index
    @tag_cloud = {}
    # can join game list here to scope game àor account game directly i the query
    @data = Tagging.find(:all, :include => :tag,
                         :conditions => ["taggings.taggable_type == ?", Game.acts_as_taggable_options[:taggable_type]])
    # to scope this to only auser account_game just reject taggings with game not include in account_games
    @cloud = {}
    @data.group_by(&:tag).each do |tag, taggings|
      @cloud[tag.name] = taggings.size
    end
    @cloud = @cloud.sort
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
    @games = Game.find(:all, :conditions => {:id => ids}, :include => :image)
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

end

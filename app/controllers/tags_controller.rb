class TagsController < ApplicationController
  def index
    @tag_cloud = {}
    # can join game list here to scope game �or account game directly i the query
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

end

# encoding: UTF-8
class TagsController < ApplicationController
  subnav :games

  def index
    respond_to do |format|
      format.html do
        @cloud = ActsAsTaggableOn::Tagging.where(taggings: { taggable_type: 'Game' })
        @cloud = @cloud.group(:tag).order('count_id desc').count(:id)
        @first_letters = @cloud.keys { |tag| tag.name.first.downcase }
        @cloud = @cloud.to_a.paginate(page: params[:page])
      end

      format.text do
        if params[:game_id]
          tags = Game.find(params[:game_id]).tag_list
        end
        render text: tags
      end
    end
  end

  def lookup
    @tags = ActsAsTaggableOn::Tag.find(:all)
    respond_to do |format|
      format.json { render json: @tags.map(&:name).to_json }
    end
  end

  def show
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:id])
    if @tag
      ids = @tag.taggings.where(taggable_type: Game).pluck(:taggable_id)
      @games = Game.where(id: ids).order(:name).paginate(page: params[:page])
    else
      @games = []
      @tag = Tag.new(name: params[:id])
    end
  end


  def create
    @game = Game.find(params[:game_id])
    @game.tag_with(params[:value])
    render partial: :tag_list
  end

  def edit
    @tag = Tag.find_by_name(params[:id])
  end

  def update
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      redirect_to tags_path
    else
      render action: :edit
    end
  end

  def destroy
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    if @tag.destroy
      respond_to do |format|
        format.js
        format.html {redirect_to tags_path}
      end
    end
  end

end

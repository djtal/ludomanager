# encoding: UTF-8
class AuthorsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  subnav :authors

  def index
    opts = {
      page: params[:page],
      include: :authorships
    }
    @first_letters = Author.find(:all, select: :name).map { |a| a.name.first.downcase }.uniq
    respond_to do |format|
      format.html do
        @authors = if params[:start]
          Author.start(params[:start]).paginate(opts)
        else
          Author.paginate(opts)
        end
      end
      format.json do
        @authors = Author.find(:all, order: 'surname ASC' )
        render json: @authors.map(&:display_name).to_json
      end
    end
  end

  def show
    @author = Author.find(params[:id])
    @games = @author.games.paginate(page: params[:page], include: :editions, order: 'editions.created_at ASC' )
  end

  def new
    @author = Author.new
  end

  def edit
    @author = Author.find(params[:id])
  end

  def create
    @author = Author.new(params[:author])
    if @author.save
      redirect_to author_url(@author)
    else
      render action: :new
    end
  end

  def update
    @author = Author.find(params[:id])

    if @author.update_attributes(params[:author])
      flash[:notice] = 'Author was successfully updated.'
      redirect_to author_url(@author)
    else
      render action: :edit
    end
  end

  def destroy
    @author = Author.find(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to authors_url }
      format.js
    end
  end

  protected

  def set_section
    @section = :authors
  end
end

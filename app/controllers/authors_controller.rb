# encoding: UTF-8
class AuthorsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  subnav :authors

  def index
    @first_letters = Author.where.not(surname: nil).pluck(:surname).map { |name| name.first.downcase }.uniq
    respond_to do |format|
      format.html do
        @authors = if params[:start]
          Author.start(params[:start]).paginate(opts)
        else
          Author.includes(:authorships).paginate(page: params[:page], per_page: 15)
        end
      end
      format.json do
        @authors = Author.find(:all, order: 'surname ASC' )
        render json: @authors.map(&:display_name).to_json
      end
    end
  end

  def show
    @author = Author.find_by_id(params[:id])
    @games = @author.games.includes(:editions).order('editions.created_at asc').paginate(page: params[:page])
  end

  def new
    @author = Author.new
  end

  def edit
    @author = Author.find_by_id(params[:id])
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      redirect_to @author, notice: "Auteur creer avec succes"
    else
      render action: :new
    end
  end

  def update
    @author = Author.find_by_id(params[:id])

    if @author.update_attributes(author_params)
      redirect_to @author, notice: "Auteur mis a jour"
    else
      render action: :edit
    end
  end

  def destroy
    @author = Author.find_by_id(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to authors_url }
      format.js
    end
  end

  protected

  def author_params
    params.require(:author).permit(:name, :surname, :lang, :homepage)
  end


  def set_section
    @section = :authors
  end
end

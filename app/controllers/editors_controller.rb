# encoding: UTF-8
class EditorsController < ApplicationController
  before_filter :login_required, except: [:index, :show, :search]
  subnav :editors

  def index
    @editors = if params[:start]
      Editor.start(params[:start]).paginate(page: params[:page])
    else
      Editor.order(:name).paginate(page: params[:page])
    end

    @first_letters = Editor.pluck(:name).map { |name| name.first.downcase }.uniq
    @last_active = Edition.includes(:editor).limit(10).group(:editor_id).order('editions.published_at DESC, editions.created_at DESC')
    @last_active = @last_active.map(&:editor)
  end

  def search
    @editors = Editor.where("LOWER(name) LIKE ?", "%#{params[:search].downcase}").order(:name)
    @editors = @editors.paginate( page: params[:page])
    render action: :index
  end

  def show
    @editor = Editor.includes(:editions).find_by_id(params[:id])
    editions = @editor.editions.includes(:game).order(:published_at)
    yearly = editions.reject { |ed| ed.published_at.nil? }
    blank = editions.select { |ed| ed.published_at.nil? }
    @editions = yearly.group_by { |e| e.published_at.year }
    @editions["blank"] = blank if blank.any?
  end

  def new
    @editor = Editor.new
  end

  def edit
    @editor = Editor.find(params[:id])
  end

  def create
    @editor = Editor.new(params[:editor])

    if @editor.save
      flash[:notice] = 'Editor was successfully created.'
      redirect_to(@editor)
    else
      render action: :new
    end
  end

  def update
    @editor = Editor.find(params[:id])

    if @editor.update_attributes(params[:editor])
      flash[:notice] = 'Editor was successfully updated.'
      redirect_to @editor
    else
      render action: :edit
    end
  end

  def destroy
    @editor = Editor.find(params[:id])
    @editor.destroy

    respond_to do |format|
      format.html { redirect_to(editors_url) }
      format.js
    end
  end

  def set_section
  	@section = :editors
  end

end

# encoding: UTF-8
class EditorsController < ApplicationController
  before_filter :login_required, except: [:index, :show, :search]
  subnav :editors

  def index
    @editors = if params[:start]
      Editor.start(params[:start]).paginate(page: params[:page])
    else
      Editor.paginate(order: 'name ASC', page: params[:page])
    end

    @first_letters = Editor.find(:all, select: :name).map { |e| e.name.first.downcase }.uniq
    @last_active = Edition.find(:all,  order: 'editions.published_at DESC, editions.created_at DESC',
                                       group: :editor_id,
                                       include: :editor, limit: 10).map(&:editor)
  end

  def search
    @editors = Editor.paginate( page: params[:page],
                                conditions: ["LOWER(name) LIKE ?","%#{params[:search].downcase}%"],
                                order: 'name ASC')
    render action: :index
  end

  def show
    @editor = Editor.find(params[:id], include: :editions)
    editions = @editor.editions.find(:all, order: 'published_at DESC', include: { game: :editors } )
    yearly = editions.reject { |ed| ed.published_at.nil? }
    blank = editions.select { |ed| ed.published_at.nil? }
    @editions = yearly.group_by{ |e| e.published_at.year }
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

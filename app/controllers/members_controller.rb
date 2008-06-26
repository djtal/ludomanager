class MembersController < ApplicationController
  before_filter :login_required
  
  def index
    @members = current_account.members.find(:all, :include => :players)
    respond_to do |format|
      format.html
      format.json{render :json => @members}
    end
  end
  
  def new
    @member = current_account.members.new
  end
  
  def create
    @member = current_account.members.build(params[:member])
    if @member.save
      respond_to do |format|
        format.html{ redirect_to members_path}
      end
    else
      respond_to do |format|
        format.html{ render :action => "new"}
      end
    end
  end
  
  def edit
    @member = Member.find(params[:id])
  end
  
  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      respond_to do |format|
        format.html{ redirect_to members_path}
      end
    else
      respond_to do |format|
        format.html{ render :action => "edit"}
      end
    end
  end
  
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    respond_to do |format|
      format.html {redirect_to members_path}
      format.js
    end
  end
  
  protected
  
  def set_section
    @section = :members
  end
  
end

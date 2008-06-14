class SmartListsController < ApplicationController
  before_filter :login_required
  
  def index
    @smart_lists = current_account.smart_lists.find(:all, :order => "created_at DESC")
    respond_to do |format|
      format.html
    end
  end

  def create
    @list = SmartList.new(params[:smart_list])
    @list.account = current_account
    @list.query = params[:search]
    @list.save
    respond_to do |format|
      format.js
    end
  end
  
  def show
     @smart_list = SmartList.find(params[:id])
     respond_to do |format|
       format.html { redirect_to(all_account_games_path(:search => @smart_list.query)) }
       format.js
       format.xml  { head :ok }
     end
  end
  
  def destroy
    @smart_list = SmartList.find(params[:id])
    @smart_list.destroy

    respond_to do |format|
      format.html { redirect_to smart_lists_url }
      format.js
      format.xml  { head :ok }
    end
  end
  
  private
  
  def set_section
    @section = :smart_lists
  end
end

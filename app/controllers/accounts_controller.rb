class AccountsController < ApplicationController
  before_filter :login_required, :only => [:show] 
  # render new.rhtml
  def new
  end

  def create
    @account = Account.new(params[:account])
    @account.save!
    self.current_account = @account
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
end

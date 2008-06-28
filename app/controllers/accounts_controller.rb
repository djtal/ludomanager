class AccountsController < ApplicationController

  
  def show
    
  end
  
  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @account = Account.new(params[:account])
    @account.save
    if @account.errors.empty?
      self.current_account = @account
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def edit
    @account = current_account
  end
  
  def update
    if current_account.update_attributes(params[:account])
      respond_to do |format|
        format.html{ redirect_to dashboard_path}
      end
  end

end

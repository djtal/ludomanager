# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout "simple"
  
  def index
    @accounts = Account.find(:all, :order => "login ASC")
  end
  
  # render new.rhtml
  def new
    @account = Account.find(:first, :conditions => {:id => params[:id]})
    self.current_account = @account
    self.current_account.remember_me
    cookies[:auth_token] = { :value => self.current_account.remember_token , :expires => self.current_account.remember_token_expires_at }
    redirect_back_or_default(dashboard_path)
  end

  def create
    self.current_account = Account.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_account.remember_me
        cookies[:auth_token] = { :value => self.current_account.remember_token , :expires => self.current_account.remember_token_expires_at }
      end
      redirect_back_or_default(dashboard_path)
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_account.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  protected
  
  def set_section
    @section = :login
  end
end

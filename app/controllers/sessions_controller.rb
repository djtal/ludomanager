# # encoding: UTF-8
# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout "simple"

  # render new.rhtml
  def new
  end

  def create
    self.current_account = Account.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_account.remember_me unless current_account.remember_token?
        cookies[:auth_token] = { value: self.current_account.remember_token , expires: self.current_account.remember_token_expires_at }
      end
      redirect_back_or_default('/dashboard')
      flash[:notice] = 'Vous etes connecté'
    else
      render action: :new
    end
  end

  def destroy
    self.current_account.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = 'Vous etes maintenant deconectez'
    redirect_back_or_default('/')
  end
end

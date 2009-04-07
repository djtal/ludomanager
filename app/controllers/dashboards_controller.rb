class DashboardsController < ApplicationController
  layout "simple"
  before_filter :login_required
  
  
  def show
    @last_buyed = current_account.account_games.find(:all, :order => "transdate DESC", :limit  =>  5)
    @last_parties = current_account.parties.last_play(5).group_by(&:game)
    @most_played = current_account.parties.most_played(5)
    @played_games = current_account.parties.count(:game_id, :distinct => true)
    
    @parties_breakdown = current_account.parties.yearly_breakdown(3.year.ago.year, Time.now.year)
  protected
  
  
  def set_section
    @section = :dashboard
  end
end

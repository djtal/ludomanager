# encoding: UTF-8

class DashboardsController < ApplicationController
  layout 'simple'
  before_filter :login_required

  def show
    @last_buyed = current_account.account_games.order(transdate: :desc).limit(5)
    @last_parties = current_account.parties.last_play(5).group_by(&:game)
    @most_played = current_account.parties.most_played
    @played_games = current_account.parties.count(:game_id, distinct: true)
    @today = Time.zone.now
    @parties_breakdown = current_account.parties.yearly_breakdown(current_account.parties.play_range)
  end

  protected


  def set_section
    @section = :dashboard
  end
end

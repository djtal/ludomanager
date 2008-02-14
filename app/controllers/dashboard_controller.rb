class DashboardController < ApplicationController
  layout "simple"
  before_filter :login_required
  
  
  def index
    @games = current_account.account_games.find(:all, :include => :game, :order => "account_games.created_at DESC")
    @parties = current_account.parties
    @parties_count = @parties.count
    @last_played = @parties.last_played
    @most_played = @parties.played_games.first(5)
    @parties_overview = {}
    @start = 1.years.ago.beginning_of_year
    @end = Time.now.end_of_year
    @years_total = [0, 0]
    if (!@parties.empty?)
      parties = @parties.group_by{ |p| p.created_at.year}
      cur_year = parties[@end.year]
      last_year = parties[@start.year]
      @years_total = [last_year.size, cur_year.size]
      cur_year = cur_year.group_by{ |p| p.created_at.month}
      last_year = last_year.group_by{ |p| p.created_at.month}
      (1..12).each do |month|
        cur_count = last_count = 0
        cur_count = cur_year[month].size if cur_year[month]
        last_count = last_year[month].size if last_year[month]
        @parties_overview[month] = [last_count, cur_count]
      end
      @parties_overview = @parties_overview.sort
    end
  end
  
  protected
  
  
  def set_section
    @section = :dashboard
  end
end

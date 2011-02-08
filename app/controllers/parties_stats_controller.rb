class PartiesStatsController < ApplicationController
  layout "simple"
  subnav :parties
  
  def show
    @date = Time.zone.parse(params[:date])
    parties = current_account.parties.by_day(@date) do
      {:include => :game}
    end
    @by_player = parties.count(:group => :nb_player)
    @by_time = parties.count(:group => "games.time_category")
    @by_target = parties.count(:group => "games.target")
    @date = @date.to_date
  end
  
end

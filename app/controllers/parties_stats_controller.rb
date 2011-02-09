class PartiesStatsController < ApplicationController
  layout "simple"
  subnav :parties
  
  def show
    @date = Time.zone.parse(params[:date])
    parties = current_account.parties.by_day(@date) do
      {:include => :game}
    end
    count = parties.count(:all)
    @by_player = parties.count(:group => :nb_player).inject({}){|acc, (key, value)| acc[key] = (value.to_f/count)*100; acc}
    @by_time = parties.count(:group => "games.time_category").inject({}){|acc, (key, value)| acc[key] = (value.to_f/count)*100; acc}
    @by_target = parties.count(:group => "games.target").inject({}){|acc, (key, value)| acc[key] = (value.to_f/count)*100; acc}
    @date = @date.to_date
  end
  
end

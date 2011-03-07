class PlayedGamesController < ApplicationController
  subnav :parties
  layout "simple"
  
  def show
    @game = Game.find(params[:id])
    
    respond_to do |format|
      format.html do
        @range = current_account.parties.play_range(:game => @game)
        options = {
          :game => @game
        }.merge(@range)
        data = current_account.parties.yearly_breakdown(options)
        breakdown = data.values.flatten
        year = breakdown.size/12
        @chart = Gchart.new(  :type => :bar,
                              :size => '670x200', 
                              :alt => "Evolution des parties par mois",
                              :bg => {:color => 'efefef', :type => 'gradient'},
                              :axis_with_labels => ['x', 'y'], 
                              :axis_labels => [(1..12).map{|m| t('date.month_names')[m].first} * year], 
                              :axis_range => [nil, [breakdown.min, breakdown.max, 1]],
                              :data => breakdown)
        @yearly = data.inject([]) do |acc, stats|
          acc << stats[1].sum
        end  
      end
    end
  end
  
end

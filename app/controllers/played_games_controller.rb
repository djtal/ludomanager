class PlayedGamesController < ApplicationController
  
  def show
    @game = Game.find(params[:id])
    @parties = current_account.parties.find_all_by_game_id(@game.id, :order => "created_at ASC")
    options = {
      :game => @game
    }.merge(current_account.parties.play_range(:game => @game))
    @breakdown = current_account.parties.yearly_breakdown(options).values.flatten
    year = @breakdown.size/12

    @chart = Gchart.new(  :type => :bar,
                          :size => '670x200', 
                          :alt => "Evolution des parties par mois",
                          :bg => {:color => 'efefef', :type => 'gradient'},
                          :axis_with_labels => ['x', 'y'], 
                          :axis_labels => [(1..12).map{|m| t('date.month_names')[m].first} * year], 
                          :axis_range => [nil, [@breakdown.min, @breakdown.max, 1]],
                          :data => @breakdown)
    
    respond_to do |format|
      format.html
    end
  end
  
end

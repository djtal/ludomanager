class PlayersController < ApplicationController
  
  
  
  def new
    @party = current_account.parties.find(params[:party_id])
    @parties = current_account.parties.find_all_by_created_at(@party.created_at)
  end
  
  def edit
    @party = current_account.parties.find(params[:party_id])
    @parties = current_account.parties.find_all_by_created_at(@party.created_at)
  end
  
  def create
    logger.debug { params[:party][:player].values.select{|player| player[:member_id] != ""}.inspect }
    Player.create(params[:party][:player].values.select{|player| player[:member_id] != ""})
    party = Party.find(params[:party][:player].values.first[:party_id])
    respond_to do |format|
      format.html{ redirect_to party_path(party)}
    end
  end
  
  
end

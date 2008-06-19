class PlayersController < ApplicationController
  
  def new
    @party = current_account.parties.find(params[:party_id])
    @parties = current_account.parties.find_all_by_created_at(@party.created_at)
  end
end

class PlayersController < ApplicationController
  before_filter :login_required
  
  
  def new
    @party = current_account.parties.find(params[:party_id])
    @parties = current_account.parties.find_all_by_created_at(@party.created_at)
  end
  
  def new_partial_form
    @index = params[:index].to_i || 0
    @party = Party.find(params[:party_id])
    @index += 1
    @player = @party.players.build
  end
  
  def edit
    @party = current_account.parties.find(params[:party_id])
    @parties = current_account.parties.find_all_by_created_at(@party.created_at)
  end
  
  def create
    Player.create(params[:player].values.select{|player| player[:member_id] != ""})
    @party = Party.find(params[:player].values.first[:party_id])
    if (params[:players][:save_and_next] == "1")
      index = @parties.rindex(@party)
      next_party = @parties[index + 1] ? @parties[index + 1] : @parties.first
      redirect_path = next_party.players.size > 0 ? edit_party_player_url(next_party, next_party) : new_party_player_url(next_party, next_party) 
    else
      redirect_path = party_path(@party)
    end
    respond_to do |format|
      format.html{ redirect_to redirect_path}
    end
  end
  
  
  def update
    @party = Party.find(params[:party_id])
    @party.players.delete_all
    Player.create(params[:player].values.select{|player| player[:member_id] != ""})
    @parties = current_account.parties.find_all_by_created_at(@party.created_at, :order => "created_at DESC")
    if (params[:players][:save_and_next] == "1")
      index = @parties.rindex(@party)
      next_party = @parties[index + 1] ? @parties[index + 1] : @parties.first
      redirect_path = next_party.players.size > 0 ? edit_party_player_url(next_party, next_party) : new_party_player_url(next_party, next_party) 
    else
      redirect_path = party_path(@party)
    end
    redirect_to redirect_path
  end
  
  protected
  
  def set_section
    @section = :parties
  end
  
end

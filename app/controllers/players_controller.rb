class PlayersController < ApplicationController
  
  
  
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
    party = Party.find(params[:player].values.first[:party_id])
    respond_to do |format|
      format.html{ redirect_to party_path(party)}
    end
  end
  
  def show
    @authorship = Authorship.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @authorship.to_xml }
    end
  end
  
end

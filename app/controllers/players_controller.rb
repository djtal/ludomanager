class PlayersController < ApplicationController
  before_filter :login_required
  
  
  def new
    @party = current_account.parties.find(params[:party_id], :include => :game)
    @parties = current_account.parties.find_all_by_created_at(@party.created_at, :include => [:players, :game])
  end
  
  def new_partial_form
    @index = params[:index].to_i || 0
    @party = Party.find(params[:party_id])
    @index += 1
    @player = @party.players.build
  end
  
  def edit
    @party = current_account.parties.find(params[:party_id], :include => :game)
    @game = @party.game
    @parties = current_account.parties.find_all_by_created_at(@party.created_at, :include => [:players, :game])
  end
  
  def create
    Player.create(params[:player].values.select{|player| player[:member_id] != ""})
    @party = Party.find(params[:player].values.first[:party_id])
    
    respond_to do |format|
      format.html{ redirect_to(next_party_path_for(@party, params[:players][:save_and_next] == "1"))}
    end
  end
  
  
  def update
    @party = Party.find(params[:party_id])
    @party.players.delete_all
    Player.create(params[:player].values.select{|player| player[:member_id] != ""})
    respond_to do |format|
      format.html{ redirect_to(next_party_path_for(@party, params[:players][:save_and_next] == "1"))}
    end
  end
  
  protected
  
  def find_next_to_register(current_party, date)
    @parties = current_account.parties.find_all_by_created_at(date, :order => "created_at DESC")
    #get postion of current party
    cur = @parties.rindex(current_party)
    #advance from one if possible otherwise return to begening
    next_index = cur + 1 <= @parties.size ? cur + 1 : 1
    @parties[next_index]
  end
  
  def next_party_path_for(party, go_next)
     if (go_next)
        next_party = find_next_to_register(party, party.created_at)
        redirect_path = if next_party.players.size > 0
          edit_party_player_url(next_party, next_party)
        else
          new_party_player_url(next_party)
        end
      else
        redirect_path = party_path(party)
      end
      redirect_path
  end

  
  def set_section
    @section = :parties
  end
  
end

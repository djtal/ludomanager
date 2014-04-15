# encoding: UTF-8
module PlayersHelper

  def add_player_link(party)
    if party.players.size > 0
      link_to(party.game.name, game_path(party.game))
    elsif party.players.size == 0
       link_to(party.game.name, new_party_player_path(party))
    end
  end

end

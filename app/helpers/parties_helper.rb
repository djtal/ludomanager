# encoding: UTF-8
module PartiesHelper


 def  account_game_status_for(game)
   content_tag(:span, "", class: "ss_sprite ss_flag_green") if account_have_game?(game)
 end

 #display a game nmae according the selected mode used in calendar cell
 # :simple the name is trucated
 # :advanced the name is fully displayed
 #
 def game_name_for(game, parties, mode = :simple)
    name = ""
    if mode == :simple
      name = truncate(game.name, length: parties > 1 ? 9 : 12)
    elsif mode == :advanced
      name = game.name
    end
 end
end

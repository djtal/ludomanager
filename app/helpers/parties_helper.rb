module PartiesHelper
 
 def last_play_date_table_cell(game)
   time_ago_in_words(@last_played[game])
 end
 
 def  account_game_status_for(game)
   content_tag(:span, "", :class => "ss_sprite ss_flag_green") if account_have_game?(game)
 end
end

module PartiesHelper
 
 def last_play_date_table_cell(game)
   time_ago_in_words(@last_played[game])
 end
 
 def  account_game_status_for(game)
   image_tag("modified.png", :size => "16x16") if account_have_game?(game)
 end
end

module PartiesHelper
  def render_parties(group, opts= {})
    text = ""
    if group.size > 0
      table_id = "id=\"#{opts[:id]}\"" if opts[:id]
      text = "<table class=\"sortable\" #{table_id if table_id}>"
    	text +="<thead><tr><th class=\"nosort\">S</th><th>Nom</th><th>Derniere partie</th><th>Nb Parties</th></tr></thead>"
    	text += "<tbody>"
      group.each do |game, parties|
    		text << render(:partial => "party", :locals => {:game => game, :parties => parties})
    	end
    	text += "</tbody>"
    	text += "</table>"
    else
      text = content_tag(:p, "Vous n'avez pour l'instat aucune parties dans cette categorie", :class => "empty")
    end
    text
 end
 
 def has_game?(g)
   @account_games.include?(g)
 end
 
 def first_play_date(parties)
   parties.sort_by(&:created_at).first.created_at
 end
 
 def last_play_date(parties)
   parties.sort_by(&:created_at).last.created_at
 end
 
 def elapsed_time_for_partie(parties)
   ((last_play_date(parties) - first_play_date(parties)) / 1.day).to_i + 1
 end
 
 def  account_game_status_for(game)
   content_tag(:span, "&nbsp", :class => has_game?(game) ? "ss_bullet_green  ss_sprite" : "")
 end
end

module PartiesHelper
  def render_parties(group, options= {})
    opts = {
      :class => "sortable"
    }.merge(options)
    result_id = ""
    result_id = "id=\"#{opts[:id]}-results\"" if opts[:id]
    if group.size > 0
    	text ="<thead><tr><th class=\"nosort span-1\">S</th><th class=\"span-11\">Nom</th><th class=\"span-3\">Derniere partie</th><th class=\"span-2\">Nb Parties</th></tr></thead>"
    	text += "<tbody #{result_id}>"
      group.each do |game, parties|
    		text << render(:partial => "party", :locals => {:game => game, :parties => parties})
    	end
    	text += "</tbody>"
      content_tag(:table, text, opts)
    else
     content_tag(:p, "Vous n'avez pour l'instat aucune parties dans cette categorie", :class => "empty")
    end
 end
 
 def last_play_date_table_cell(game)
   time_ago_in_words(@last_played[game])
 end
 
 def  account_game_status_for(game)
   content_tag(:span, "&nbsp", :class => account_have_game?(game) ? "ss_bullet_green  ss_sprite" : "")
 end
end

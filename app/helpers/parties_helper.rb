module PartiesHelper
  def render_parties(group, options= {})
    opts = {
      :class => "sortable"
    }.merge(options)
   
    if group.size > 0
    	text ="<thead><tr><th class=\"nosort span-1\">S</th><th class=\"span-11\">Nom</th><th class=\"span-3\">Derniere partie</th><th class=\"span-2\">Nb Parties</th></tr></thead>"
    	text += "<tbody>"
      group.each do |game, parties|
    		text << render(:partial => "party", :locals => {:game => game, :parties => parties})
    	end
    	text += "</tbody>"
      content_tag(:table, text, opts)
    else
     content_tag(:p, "Vous n'avez pour l'instat aucune parties dans cette categorie", :class => "empty")
    end
 end
 
 def last_play_date_table_cell(parties)
   #<span class="hide"><%= last_play_date(parties).to_s(:date_fr) %></span><%= time_ago_in_words(last_play_date(parties)) %>
   content_tag(:span, last_play_date(parties).to_s(:table), :class => "hide") + time_ago_in_words(last_play_date(parties))
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

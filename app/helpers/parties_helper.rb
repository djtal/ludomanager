module PartiesHelper
  def render_parties(group, options= {})
    opts = {
      :class => "sortable"
    }.merge(options)
    result_id = ""
    result_id = "id=\"#{opts[:id]}-results\"" if opts[:id]
    if group.size > 0
    	text ="<thead><tr><th class=\"nosort span-1\">S</th><th class=\"span-10\">Nom</th><th class=\"span-3\">Derniere partie</th><th class=\"span-2\">Nb Parties</th><th class=\"span-1\">Taux</th></tr></thead>"
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
 
 def  play_time(parties)
  ((Time.now - first_play_date(parties)) / 1.month)
 end
 
 def  month_rate(parties)
    by, ey = Time.now.beginning_of_year, Time.now
    duration = ((ey - by) /1.month)
    p = parties.select{|pa| pa.created_at >= by && pa.created_at <= ey}
    if (!p.empty?)
      rate =  p.size.to_f / duration
    else
      rate = 0
    end
    color = if rate > 1
                :green
            elsif rate > 0.5
                :orange
            else
                :red
            end
    content_tag(:span, number_with_precision(rate, 2), :class => "#{color} color", :id => "#{dom_id(parties.first.game)}_rate")
 end

 
 def  account_game_status_for(game)
   content_tag(:span, "&nbsp", :class => has_game?(game) ? "ss_bullet_green  ss_sprite" : "")
 end
end

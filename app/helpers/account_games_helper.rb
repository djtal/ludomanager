module AccountGamesHelper

  
  
  def render_games(games, options = {})
    opts = {
      :mode => :full,
      :class => "sortable"
    }.merge(options)
    head = "<th class=\"nosort span-1\">S</th><th class=\"span-7\">Nom</th><th class=\"nosort span-8\">Status</th
    <th class=\"span-3 text\">Public</th><th class=\"nosort span-2 last\">Gerer</th><th>P</th>"
    
    extended_head = "<th class=\"nosort span-1\">S</th><th class=\"span-18 text\">Nom</th>
    <th class=\"span-9 nosort \">Tags</th><th class=\"span-1 nosort \">Joueurs</th><th class=\"span-1\">Difficulte</th>
    <th>Parties</th>"
    if games.size > 0 
      text = "<thead><tr>#{opts[:mode] == :overview ? head : extended_head}</tr></thead>"
      text += "<tbody>"
      text += render(:partial => "account_game", :collection => games, :locals =>{:mode => opts.delete(:mode)})
      text +="</tbody>"
      text = content_tag(:table, text, opts)
    else
      text = "<p class=\"empty\">Vous n'avez aucun jeux dans cette categorie.</p>"
    end
    text
  end

  def status_indicator(account_game)
    content_tag(:span, account_game.recenty_acquired? ? "" : "&nbsp;", 
                          :class => account_game.recenty_acquired? ? "ss_new ss_sprite" : "")
  end
  
  def parties_indicator(account_game)
    content_tag(:span, !account_game.played? ? "" : "&nbsp;", 
                          :class => !account_game.played? ? "ss_sprite ss_exclamation" : "")
  end
  
  def highlighted_tag_list(game)
      search_tags = @tag_list ? @tag_list : []
      game.tags.collect{|t| search_tags.include?(t.name) ? content_tag(:strong, t.name) : t.name}.join(", ")
  end
  
  def selectable_tag_list(game)
    tags_li = game.tags.inject(""){|acc, t| acc << content_tag(:li, t.name, :class => "#{t.name} tag")}
    content_tag(:ul, tags_li, :class => "tags")
  end
end

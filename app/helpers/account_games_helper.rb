module AccountGamesHelper
   def account_game_status_links_for(game)
    if (account_have_game?(game))
      link_to_remote("Supprimez de ma ludotheque", :url => {:controller => "account_games", 
      										:action => 'destroy', :game_id => game.id}, :method => :delete, :html => {:class => "ss_sprite ss_x"})
    else
      link_to_remote("L'ajouter a ma ludotheque", 	:url => account_games_path(:account_game => {"1" => {:game_id => game.id}}),
      				            :method => :post, :html => {:class => "ss_sprite ss_briefcase"})
    end
   end
  
  
  def status_indicator(account_game)
    content_tag(:span, account_game.recenty_acquired? ? "" : "&nbsp;", 
                          :class => account_game.recenty_acquired? ? "ss_coffee ss_sprite" : "")
  end
  
  def parties_indicator(account_game)
    content_tag(:span, !account_game.played? ? "" : "&nbsp;", 
                          :class => !account_game.played? ? "ss_sprite ss_error" : "")
  end
  
  
  def selectable_tag_list(game)
    tags_li = game.tags.inject(""){|acc, t| acc << content_tag(:li, t.name, :class => "#{t.name} tag")}
    content_tag(:ul, tags_li, :class => "tags")
  end
end

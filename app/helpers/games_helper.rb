module GamesHelper
  def nb_player_tag(game)
    if game.min_player < game.max_player
      "<span class=\"flash\">" + game.min_player.to_s + "</span> a <span class=\"flash\">" + pluralize(game.max_player, "</span>joueur", "</span>joueurs")
    else
      "<span class='flash'>#{pluralize(game.max_player, "</span>joueur", "</span>joueurs")}"
    end
  end
  
  def game_name(game, includeVO = true)
    name = game.name
    game +=  content_tag(:span, " (" + game.vo_name + ")") if (!game.vo_name.blank? && includeVO)
    
  end

  def tags_links(game)
    game.tags.collect do |tag|
      link_to(tag.name, :action => "tags", :tag => tag.name)
    end.join(", ")
  end
  
  def game_tags_links(game)
    game.tags.collect do |tag|
      link_to(tag.name, tag_path(tag.name))
    end.join(", ")
  end
  
  def average_for(game)
    "<span class=\"hide average\">#{@game.average}</span><span class=\"rate\"></span>"
  end
  
  def authors_links(game)
    if game.authorships.size > 0
      links = game.authors.collect do | a|
        a ? link_to(a.display_name, author_path(a)) : ""
      end.compact.join(", ")
    else
      links = link_to("Ajouter des auteurs", new_game_authorship_path(game))
    end
  end
  
  def game_box_for(game, opts = {})
    options = {
      :size => "35x35",
      :alt => "boite_#{!game.new_record? ? game.name.gsub(/\s+/, "_").downcase : ''}"
    }.merge(opts)
    image_tag(game.image ? game.image.public_filename : "game_box.png" , options)
  end
  
  # Return all foreign game name for an editions list
  #
  def other_name_for(game, editions )
    txt = editions.map{|e| e.name unless e.name.blank? }.uniq.compact * " , "
    txt = "(#{txt})" if txt
  end
end

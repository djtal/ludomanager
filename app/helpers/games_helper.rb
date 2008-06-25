module GamesHelper
  def nb_player_tag(game)
    "De <span class=\"flash\">" + game.min_player.to_s + "</span> a <span class=\"flash\">" + pluralize(game.max_player, "</span>joueur", "</span>joueurs")
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
  
  def authors_links(authors)
    authors.collect do |a|
      link_to(a.display_name, author_path(a))
    end.join(", ")
  end
  
  def game_box_for(game, opts = {})
    options = {
      :size => "35x35"
    }.merge(opts)
    image_tag(game.image.public_filename , options) if game.image
  end
end

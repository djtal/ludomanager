module GamesHelper
  
  def show_extension_tab(game)
    @show_extension_tab ||= game.base_game || game.extensions.count > 0
    @show_extension_tab
  end
  
  
  def nb_player_tag(game)
    if game.min_player < game.max_player
      "<span class=\"flash\">" + game.min_player.to_s + "</span> a <span class=\"flash\">" + pluralize(game.max_player, "</span>joueur", "</span>joueurs")
    else
      "<span class='flash'>#{pluralize(game.max_player, "</span>joueur", "</span>joueurs")}"
    end
  end

  
  def game_tags_links(game)
    if game.tags.size > 0
      game.tags.collect do |tag|
        link_to(tag.name, tag_path(tag.name), :class => "tag #{tag.name}")
      end
    else
      content_tag(:span,"Ce jeux n'est pas encore categoris&eacute;", :class => "empty" )
    end
  end

  def authors_links(game)
    if game.authorships.size > 0
      game.authors.collect do | a|
        a ? link_to(a.display_name, author_path(a)) : ""
      end.compact.join(", ")
    else
      content_tag(:span, "Ce jeu ne possede pas encore d'auteurs;", :class => "empty")
    end
  end
  
  # use a new or edit path for games authors if have any
  #
  def manage_authors_link(game)

    if game.authorships.size > 0
      link_to("Gerer les auteur", edit_game_authorship_path(@game), :class => "ss_sprite ss_add_user")
    else
      link_to("Gerer les auteur", new_game_authorship_path(@game), :class => "ss_sprite ss_add_user")
    end
  end
  
  # Return all foreign game name for an editions list
  #
  def other_name_for(game, editions )
    txt = editions.map{|e| e.name unless e.name.blank? }.uniq.compact * " , "
    txt = "(#{txt})" unless txt.blank?
  end
  
  def langs_flag_for(game)
    game.editions.map(&:lang).uniq.inject("") do |acc, lang|
      css = css_for_lang(lang)
      acc << content_tag(:span, "", :class => "right ss_flag #{css}")
    end
  end
  
  def external_game_link(game)
    if (!game.url.blank?)
      link_to("Allez voir", @game.url)
    else
      "--"
    end
  end
  
end

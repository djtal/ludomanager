# encoding: UTF-8
module GamesHelper

  def show_extension_tab(game)
    @show_extension_tab ||= game.extensions.count > 0
    @show_extension_tab
  end

  def ac_game_status_link_to(game, only_sprite = false)
    if account_have_game?(game)
      ac = current_account.games.find_by_id(game)
      link_to(only_sprite ? "" : "Supprimez ce jeu de ma ludotheque",
                          account_game_path(ac), method: :delete,
      										html: { class: "ss_sprite ss_x" } )
    else
      link_to(only_sprite ? "" : "L'ajouter a ma ludotheque",
      	                  account_games_path(account_game: { "1" => { game_id: game.id }}),
      				            method: :post, html: { class: "ss_sprite ss_briefcase" })
    end
  end

  def nb_player_tag(game)
    if game.min_player < game.max_player
      "<span class=\"flash\">" + game.min_player.to_s + "</span> a <span class=\"flash\">" + pluralize(game.max_player, "</span>joueur", "</span>joueurs")
    else
      "<span class='flash'>#{pluralize(game.max_player, "</span>joueur", "</span>joueurs")}"
    end
  end


  def game_tags_links(game)
    if game.tags.any?
      game.tags.map {  |tag| link_to(tag.name, tag_path(tag.name), class: "tag #{tag.name}") }.join.html_safe
    else
      content_tag(:span,"Ce jeux n'est pas encore categoris&eacute;", class: "empty" )
    end
  end

  def authors_links(game)
    if game.authors
      game.authors.map { | a| link_to(a.display_name, a) }.compact.join(',').html_safe
    else
      content_tag(:span, "Ce jeu ne possede pas encore d'auteurs;", class: "empty")
    end
  end

  # use a new or edit path for games authors if have any
  #
  def manage_authors_link(game)

    if game.authorships.size > 0
      link_to("Gerer les auteur", edit_game_authorship_path(@game), class: "ss_sprite ss_add_user")
    else
      link_to("Gerer les auteur", new_game_authorship_path(@game), class: "ss_sprite ss_add_user")
    end
  end

  # Return all foreign game name for an editions list
  #
  def other_name_for(game, editions )
    return "" unless editions
    names = editions.where.not(name: "").distinct.pluck("name").compact
    "(#{names * ', '})" if names.any?
  end

  def langs_flag_for(game)
    game.editions.map(&:lang).uniq.inject("") do |acc, lang|
      css = css_for_lang(lang)
      acc << content_tag(:span, "", class: "right ss_flag #{css}")
    end.html_safe
  end

  def external_game_link(game)
    if (!game.url.blank?)
      link_to("Allez voir", @game.url)
    else
      "--"
    end
  end

end

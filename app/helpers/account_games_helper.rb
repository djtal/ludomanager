# encoding: UTF-8
module AccountGamesHelper
  def status_indicator(account_game)
    return unless account_game.recenty_acquired?
    content_tag(:span, "", class: "ss_coffee ss_sprite")
  end

  def parties_indicator(account_game)
    return if account_game.played?
    content_tag(:span, "", class: "ss_sprite ss_error")
  end


  def selectable_tag_list(game)
    tags_li = game.tags.inject(""){|acc, t| acc << content_tag(:li, t.name, class: "#{t.name} tag")}
    content_tag(:ul, tags_li, class: "tags").html_safe
  end
end

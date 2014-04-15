# encoding: UTF-8
module AccountGamesHelper
  def status_indicator(account_game)
    content_tag(:span, account_game.recenty_acquired? ? "" : "&nbsp;",
                          :class => account_game.recenty_acquired? ? "ss_coffee ss_sprite" : "")
  end

  def parties_indicator(account_game)
    content_tag(:span, !account_game.played? ? "" : "&nbsp;",
                          :class => !account_game.played? ? "ss_sprite ss_error" : "")
  end


  def selectable_tag_list(game)
    tags_li = game.tags.inject(""){|acc, t| acc << content_tag(:li, t.name, class: "#{t.name} tag")}
    content_tag(:ul, tags_li, class: "tags")
  end
end

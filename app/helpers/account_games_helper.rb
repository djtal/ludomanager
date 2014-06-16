# encoding: UTF-8
module AccountGamesHelper
  def bg_for_status(account_game)
    if !account_game.played?
      "bg-danger"
    elsif account_game.recenty_acquired?
      "bg-success"
    end
  end
  def status_indicator(account_game)
    content_tag(:ul, class:'list-inline') do
      if !account_game.played?
        concat content_tag(:li, content_tag(:span, fa_icon('warning'), class: "btn btn-default btn-circle btn-danger"))
      end
      if account_game.recenty_acquired?
        concat content_tag(:li, content_tag(:span, fa_icon('coffee'), class: "btn btn-default btn-circle btn-success"))
      end
    end
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

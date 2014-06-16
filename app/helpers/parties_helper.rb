# encoding: UTF-8
module PartiesHelper

  def custom_thead
    ->(dates) {
      Rails.logger.debug dates.inspect
      content_tag(:thead) do
        concat(content_tag(:tr) do
          capture do
            concat content_tag(:th, link_to("Precedent", parties_resume_path(date: [@prev_date.month, @prev_date.year]), class: "left"), colspan: 2)
            concat content_tag(:th, t('date.month_names')[@date.month].humanize, colspan: 3, class: "monthName")
            concat content_tag(:th, link_to("Precedent", parties_resume_path(date: [@prev_date.month, @prev_date.year]), class: "right"), colspan: 2)
          end
        end)
        concat(content_tag(:tr) do
          capture do
            dates.each do |date|
              concat content_tag(:th, t("date.abbr_day_names")[date.wday])
            end
          end
        end)
      end
    }
  end

 def  account_game_status_for(game)
   content_tag(:span, "", class: "ss_sprite ss_flag_green") if account_have_game?(game)
 end

 #display a game nmae according the selected mode used in calendar cell
 # :simple the name is trucated
 # :advanced the name is fully displayed
 #
 def game_name_for(game, parties, mode = :simple)
    name = ""
    if mode == :simple
      name = truncate(game.name, length: parties > 1 ? 9 : 12)
    elsif mode == :advanced
      name = game.name
    end
 end
end

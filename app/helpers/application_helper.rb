# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def render_widget(title, opts = {}, &block)
    html_opts = opts.delete(:html) 
    options = {
      :layout => "layouts/widget",
      :locals => {:title => title, :html_opts => html_opts}
    }.merge(opts)
    render options, &block
  end


  def main_nav_section_for(name, url, section, opts = {})
    html_class = @section == section ? "active" : ""
    html_class += " #{opts[:class]}"
    content_tag("li", @section == section ? name : link_to(name, url), :class => html_class)
  end
  
  def account_have_game?(game)
    if logged_in?
      return @account_games.map(&:game_id).include?(game.id) if @account_games
      current_account.account_games.find_by_game_id(game.id)
    end
  end
  
  def ac_game_status_for(game)
    image_tag("modified.png", :class => "ac_status right") if account_have_game?(game)
  end
  
  def link_for_first_letter(letter, url_method)
    if ((@first_letters && @first_letters.include?(letter.downcase)) ||
        !@first_letters)
      css = "current" if params[:start] && params[:start].downcase == letter.downcase
      content = link_to(letter, self.send(url_method, :start => letter))
    else
      css = "disabled"
      content = letter
    end
    content_tag(:span, content, :class => css)
  end
    
    # Wrap your buttons in standard app form presentation
    # See layout _form_buttons
    #
    def render_buttons(&block)
      render :partial => "/layouts/form", &block
    end
    
    
    def flag_for_lang(lang, opts = {})
      options = {
        :size => "16x16",
        :class => "flag"
      }.merge(opts)
      image_tag("flag/#{lang}.png",options) if lang
    end
    
    def submit_or_back_to(back_to, back_to_text = "Annuler", opts = {})
      options = {
        :submit_text => "Enregistrer"
      }.merge(opts)
      txt = "<div class=\"buttons clear\">"
      txt += "<div class=\"right\">"
      txt += "<strong>#{link_to back_to_text, back_to}</strong>	 ou #{submit_tag options[:submit_text]}"
      txt += "</div>"
      txt += "</div>"
    end
    
    def month_fr
        ["", "Janvier", "Fevrier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Aout",
              "Septembre", "Octobre", "Novembre", "Decembre"]
    end
    
    def day_fr
     ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
    end
    
    def month_name index
      names = month_fr
      names[index]
    end
    
    def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round

      case distance_in_minutes
        when 0..1
          return (distance_in_minutes == 0) ? 'moins d\' minute' : '1 minute' unless include_seconds
          case distance_in_seconds
            when 0..4   then 'less than 5 seconds'
            when 5..9   then 'less than 10 seconds'
            when 10..19 then 'less than 20 seconds'
            when 20..39 then 'half a minute'
            when 40..59 then 'less than a minute'
            else             '1 minute'
          end

        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then 'environ 1 heure'
        when 90..1439        then "environ #{(distance_in_minutes.to_f / 60.0).round} heures"
        when 1440..2879      then '1 jour'
        when 2880..43199     then "#{(distance_in_minutes / 1440).round} jours"
        when 43200..86399    then 'environ 1 mois'
        when 86400..525959   then "#{(distance_in_minutes / 43200).round} mois"
        when 525960..1051919 then 'environ 1 an'
        else                      "plus #{(distance_in_minutes / 525960).round} ans"
      end
    end
    
end

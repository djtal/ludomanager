# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def render_widget(title, opts = {}, &block)
    html_opts = opts.delete(:html) 
    locals = opts.delete(:locals) || {}
    locals.merge!({:title => title, :html_opts => html_opts})
    options = {
      :layout => "layouts/widget",
      :locals => locals
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
end

# encoding: UTF-8
module AuthorsHelper
  def published_game_date_range_for(games)
    dates = games.collect{ |g| g.publish_year != "" ? g.publish_year : nil}.compact
    if games.size == 1
      ret = "depuis #{dates.first}"
    else
      ret = "entre #{dates.first} et #{dates.last}"
    end
    ret
  end

end

# Heavily inspired by http://robots.thoughtbot.com/post/159805369/search-by-quacking-like-activerecord
#
class ACGameSearch
  attr_accessor :tags, :tags_mode, :players, :cat1, :cat2, :mode, :since, :unit
  attr_accessor :account
  
  
  def initialize(account, params = nil)
    params ||= {}
    self.account = account
    self.since = 0
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def cat1=(value)
    @cat1 = value.to_i
  end
  
  def cat2=(value)
    @cat2 = value.to_i
  end
  
  def prepare_search
    @search =  Searchlogic::Search.new(AccountGame, {:conditions => {:account_id => account.id}})
    
    if players.to_i > 0
      @search.game_min_player_lte(players)
      @search.game_max_player_gte(players)
    end
    
    if !tags.blank?
      tags_list =tags.split(/\s|,\s*|;\s*/)
      if tags_mode == "or"
        @search.game_tags_name_like_any(tags_list)
      else
        @search.game_tags_name_like_all(tags_list)
      end
    end
    
    if (cat1 && cat2)
      case(true) 
        when cat1 >= 0 && cat2 >= 0 && cat1 != cat2
          @search.game_target_is_any([cat1, cat2])
        when  cat1 >= 0 && cat2 == -1
          @search.game_target_is(cat1)
        when cat1 == -1 && cat2 >= 0
          @search.game_target_is(cat2)
      end
    end
    self.add_time_condition

    @search
  end
  
  def id
    nil
  end

  def new_record?
    true
  end
  
  
  def from_date
    @from_date ||= self.since.to_i.send(self.unit).ago.beginning_of_day
  end
  
  def is_advanced_time_used?
    (self.mode == "played" || self.mode == "not_played") && self.since > 0 &&
          (['day', 'month', 'year'].include?(self.unit))
  end
  
  def add_time_condition
    if (!is_advanced_time_used?)
      if mode == "played"
        @search.parties_count_gt(0)
      elsif mode == "not_played"
        @search.parties_count_is(0)
      end
    else
      if mode == "played"
        @search.last_play_gte(self.from_date)
      elsif mode == "not_played"
        @search.last_play_lte(self.from_date)
      end
    end
  end
end
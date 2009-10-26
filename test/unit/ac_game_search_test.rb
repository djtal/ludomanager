require File.dirname(__FILE__) + '/../test_helper'

class TestACGameSearch < ActiveSupport::TestCase
  
  should "create a new object with correct values" do
    params = {:tags => "test test1",
              :tags_mode => "or",
              :players => 4,
              :cat1 => 0,
              :cat2 => 1,
              :mode => :played,
              :since => 5,
              :unit => :months}
    acc = Factory.create(:account)          
    search = ACGameSearch.new(acc, params)
    assert_equal acc, search.account
    params.each do |field ,value|
      assert_equal value, search.send(field)
    end
  end
  
  should "Return a Searchlogic::Search object when searching" do
    acc = Factory.create(:account)    
    assert_kind_of Searchlogic::Search, ACGameSearch.new(acc).prepare_search
  end
  
  should "return all AccountGame if no attributes were given" do
    acc = Factory.create(:account)
    acc.games << Factory.create(:game, :name => "I'm the boss")
    acc.games << Factory.create(:game, :name => "Assyria")
    
    search = ACGameSearch.new(acc)
    assert_equal 2, search.prepare_search.all.length
  end
  

  should "filter player number based on min and max player on game" do
    acc = Factory.create(:account)
    acc.games << Factory.create(:game, :name => "I'm the boss", :min_player => 4, :max_player => 6)
    acc.games << Factory.create(:game, :name => "Assyria", :min_player => 2, :max_player => 4)
    
    search_4_player = ACGameSearch.new(acc, {:players => 4})
    assert_equal 2, search_4_player.prepare_search.all.length
    
    search_2_player = ACGameSearch.new(acc, {:players => 2})
    assert_equal 1, search_2_player.prepare_search.all.length
    
    search_6_player = ACGameSearch.new(acc, {:players => 6})
    assert_equal 1, search_6_player.prepare_search.all.length
  end

  context "searching with parties attribute" do
    setup do
      @acc = Factory.create(:account)
      @acc.account_games << Factory.create(:account_game,  :account => @acc, 
                                                          :game => Factory.create(:game, :name => "I'm the boss"))
      @acc.account_games << Factory.create(:account_game,  :account => @acc, 
                                                          :game => Factory.create(:game, :name => "Space Alert"))   

      ac = Factory.create(:account_game,  :account => @acc, 
                                                          :game =>  Factory.create(:game, :name => "Assyria"),
                                                          :parties_count => 1)
      ac.parties_count = 1
      ac.save
      @acc.account_games << ac
    end
    
    should "search using attr mode=played should filter played games" do
      search = ACGameSearch.new(@acc, {:mode => "played"})
      assert_equal 1, search.prepare_search.all.length
    end 

    should "search using attr mode=not_played should filter not played games" do
      search = ACGameSearch.new(@acc, {:mode => "not_played"})
      assert_equal 2, search.prepare_search.all.length
    end
  end

  
  context "searching using advance time option" do
    setup do
      @acc = Factory.create(:account)
      @acc.account_games << Factory.create(:account_game,  :account => @acc, :last_play => 2.year.ago,
                                                          :game => Factory.create(:game, :name => "White Moon"))
      @acc.account_games << Factory.create(:account_game,  :account => @acc, :last_play => 1.year.ago, 
                                                          :game => Factory.create(:game, :name => "I'm the boss"))
      @acc.account_games << Factory.create(:account_game,  :account => @acc, :last_play => 1.month.ago,
                                                          :game => Factory.create(:game, :name => "Space Alert"))
      @acc.account_games << Factory.create(:account_game,  :account => @acc, :last_play => 1.day.ago,
                                                          :game => Factory.create(:game, :name => "Stronghold"))
    end
    should "know if advance time mode is active from search attribute" do
      assert ACGameSearch.new(@acc, {:mode => "played", :since => 1, :unit => "year"}).is_advanced_time_used?
      assert !ACGameSearch.new(@acc, {:mode => "played"}).is_advanced_time_used?
      assert !ACGameSearch.new(@acc, {:mode => "played", :since => 1}).is_advanced_time_used?
    end
    
    should  "compute from date based on since, unit" do
      since1year = ACGameSearch.new(@acc, {:mode => "played", :since => 1, :unit => "year"})
      assert_equal 1.year.ago.beginning_of_day, since1year.from_date
    end
    
    should "find played games based on playing date" do
      since1year = ACGameSearch.new(@acc, {:mode => "played", :since => 1, :unit => "year"})
      assert_equal 3, since1year.prepare_search.all.length

      since1month = ACGameSearch.new(@acc, {:mode => "played", :since => 1, :unit => "month"})
      assert_equal 2, since1month.prepare_search.all.length
      
      since1day = ACGameSearch.new(@acc, {:mode => "played", :since => 1, :unit => "day"})
      assert_equal 1, since1day.prepare_search.all.length
    end
    
    should "find game not played since a time interval" do
      since1year = ACGameSearch.new(@acc, {:mode => "not_played", :since => 1, :unit => "year"})
      assert_equal 1, since1year.prepare_search.all.length
      assert_equal "White Moon", since1year.prepare_search.all.first.game.name
      
      since1month = ACGameSearch.new(@acc, {:mode => "not_played", :since => 1, :unit => "month"})
      assert_equal 2, since1month.prepare_search.all.length
      
      since1day = ACGameSearch.new(@acc, {:mode => "not_played", :since => 1, :unit => "day"})
      assert_equal 3, since1day.prepare_search.all.length
    end
  end
  

end
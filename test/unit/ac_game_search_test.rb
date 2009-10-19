require File.dirname(__FILE__) + '/../test_helper'

class TestACGameSearch < ActiveSupport::TestCase
  
  should "create a new object with correct values" do
    params = {:tags => "test test1",
              :tags_mode => "or",
              :players => 4,
              :cat1 => 0,
              :cat2 => 1,
              :mode => :played,
              :time => 5,
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
  
  should "search using attr mode=played should filter played games" do
    acc = Factory.create(:account)
    acc.account_games << Factory.create(:account_game,  :account => acc, 
                                                        :game => Factory.create(:game, :name => "I'm the boss"))
    ac = Factory.create(:account_game,  :account => acc, 
                                                        :game =>  Factory.create(:game, :name => "Assyria"),
                                                        :parties_count => 1)
    ac.parties_count = 1
    ac.save
    acc.account_games << ac
    
    search = ACGameSearch.new(acc, {:mode => "played"})
    assert_equal 1, search.prepare_search.all.length
  end 
  
  should "search using attr mode=not_played should filter not played games" do
    acc = Factory.create(:account)
    acc.account_games << Factory.create(:account_game,  :account => acc, 
                                                        :game => Factory.create(:game, :name => "I'm the boss"))
    acc.account_games << Factory.create(:account_game,  :account => acc, 
                                                        :game => Factory.create(:game, :name => "Space Alert"))   
                                                                                                             
    ac = Factory.create(:account_game,  :account => acc, 
                                                        :game =>  Factory.create(:game, :name => "Assyria"),
                                                        :parties_count => 1)
    ac.parties_count = 1
    ac.save
    acc.account_games << ac
    
    search = ACGameSearch.new(acc, {:mode => "not_played"})
    assert_equal 2, search.prepare_search.all.length
  end 
end
require 'test_helper'

class GameTest < ActiveSupport::TestCase
  context "a Game" do
    should_validate_presence_of :name, :min_player, :max_player, :difficulty
    should_validate_uniqueness_of :name, :case_sensitive => true
    should_have_many :parties
    should_have_many :editions, :authorships, :dependent => :destroy
    should_have_many :authors, :through => :authorships
    should_have_many :editors, :through => :editions
    should_have_many :tags, :through => :taggings
    #should_have_attached_file :box
    
    should_ensure_value_in_range :difficulty, (1..5)
    
    should "have max player greater than min player" do
      assert_bad_value(Factory.build(:game), :max_player, 1,
                        "le nombre maxi de joueur ne peut etre inferieur au nombre mini")
      
    end
    
    should "not be deleted if owned by ome user" do
      assert !games(:battlelore).destroy
    end
    
    should "not be deleted if users have registered parties" do
      assert !games(:ever_played).destroy
    end
  
    should "return an array of available language" do
      assert_equal [], games(:coloreto).available_lang
      assert_equal ["fr","en"], games(:battlelore).available_lang
    end
    
  end
  

  
  context "searching for a game" do
    should "consider editions name's when searching for a game name" do
      assert_equal [games(:funkenshlag), games(:megamix)], Game.search("mega")
    end
    
    should "be case insensitive" do
      assert_equal [games(:battlelore)], Game.search("battle")
      assert_equal [games(:battlelore)], Game.search("BaTtLe")
    end
    
    should "return array if no search terms are supplied" do
      assert_equal [], Game.search
    end
  end
  
end

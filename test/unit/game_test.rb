require 'test_helper'

class GameTest < ActiveSupport::TestCase
  context "a Game" do
    should_have_db_columns :base_game_id, :standalone
    
    should_validate_presence_of :name, :min_player, :max_player, :difficulty
    should_validate_uniqueness_of :name, :case_sensitive => true
    should_have_many :extensions, :dependent => :nullify
    should_belong_to :base_game
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
    
    should "return blank string if no tags defined" do
      game = Factory.create(:game, :name => "Hammster Roll")
      assert_equal("", game.tag_list)
    end
    
    should "know if is an extension" do
      game = Factory.create(:game)
      assert !game.extension?
      extension = Factory.create(:extension)
      assert extension.extension?
    end
    
  end
  
  
  context "base_games named_scope" do
    setup do
      @base = Factory(:game)
      5.times do
        Factory(:game)
        Factory(:extension, :base_game => @base)
      end
    end
    
    should_have_named_scope :base_games
    
    should "return only base games ie not extension" do
      base_games = Game.base_games
      base_games.each do |b|
        assert !b.base_game_id
      end
    end
    
    context "standalone extension" do
      setup do
        @standalone = Factory(:standalone, :base_game  => @base)
      end

      should "return base game and standalone extension" do
        bases = Game.base_games.find(:all)
        assert bases.include?(@standalone)
      end
    end
    
  end
  
  context "extensions named_scope" do
    setup do
      base = Factory(:game)
      5.times do
        Factory(:game)
        Factory(:extension, :base_game => base)
      end
    end
    
    should_have_named_scope :extensions
    
    should "return only base games ie not extension" do
      extensions = Game.extensions
      extensions.each do |ext|
        assert ext.base_game_id
      end
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
  
  context "an Extension" do
    should "get base game tag list if no tags defined on extension" do
      base =Factory.create(:game, :name => "Race for the Galaxy")
      base.tag_with("card sc-fi")
      extension = Factory.create(:extension, :base_game => base)
      assert_equal(base.tag_list, extension.tag_list)
    end
    
    
    should "copy tags from base game if no tags defined when created" do
      base_game = Factory.create(:game, :name => "Race For the Galaxy", 
                                        :min_player => 3, :max_player => 5)
      base_game.tag_with("card-driven,sc-fi")
      extension = Factory.build(:extension, :base_game => base_game)
      assert extension.save
      extension = Game.find(extension.id)
      assert_equal "card-driven,sc-fi", extension.tag_list
    end
    
    should "copy tags when adding an exinsting game as an extension for another game if no tags defined" do
      base_game = Factory.create(:game, :name => "Race For the Galaxy", 
                                        :min_player => 3, :max_player => 5)
      base_game.tag_with("card-driven,sc-fi")
      assert_equal "card-driven,sc-fi", base_game.tag_list 
      extension = Factory.create(:game, :name => "Rebel vs Imperium")
      assert_equal "", extension.tag_list
      base_game.extensions << extension
      extension = Game.find(extension.id)
      assert_equal "card-driven,sc-fi", extension.tag_list
    end
    
    should "copy tags if a game become a extension : ie add a base_game_id to the game" do
      base_game = Factory.create(:game, :name => "Race For the Galaxy", 
                                        :min_player => 3, :max_player => 5)
      base_game.tag_with("card-driven,sc-fi")
      assert_equal "card-driven,sc-fi", base_game.tag_list 
      extension = Factory.create(:game, :name => "Rebel vs Imperium")
      assert_equal "", extension.tag_list
      extension.base_game = base_game
      extension.save
      extension = Game.find(extension.id)
      assert_equal "card-driven,sc-fi", extension.tag_list
    end
    
    should "not duplicate tags when copying" do
      base_game = Factory.create(:game, :name => "Race For the Galaxy", 
                                        :min_player => 3, :max_player => 5)
      base_game.tag_with("card-driven,sc-fi")
      assert_equal "card-driven,sc-fi", base_game.tag_list 
      extension = Factory.create(:game, :name => "Rebel vs Imperium")
      extension.tag_with("card-driven,sc-fi, test")
      extension.base_game = base_game
      extension.save
      extension = Game.find(extension.id)
      assert_equal "card-driven,sc-fi,test", extension.tag_list
    end
    
  end
  
end

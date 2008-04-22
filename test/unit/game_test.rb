require File.dirname(__FILE__) + '/../test_helper'

context "Game" do
  fixtures :games, :parties, :accounts, :authors, :account_games, :authorships
  specify "should have a title" do
    assert_invalid clean_game(), :name, nil, ""
  end
  
  specify "should have a difficulty level" do
    assert_invalid clean_game, :difficulty, nil, 0
  end
  
  specify "difficulty should be in range" do
    assert_invalid clean_game, :difficulty, -1, 6, 1000
  end

  specify "game should be unique" do
    assert clean_game(:name => "test").save
    assert_invalid clean_game, :name, "test"
  end
  

  specify "min and max player should be mandatory and not null" do
    assert_invalid clean_game, :max_player, 0, nil
    assert_invalid clean_game, :min_player, 0, nil
  end
  
  specify "max_player should be greater than min_player and mandatory" do  
    assert_invalid clean_game(:min_player => 4), :max_player, 3
  end
  
  specify "game should be taggable" do
    assert games(:battlelore).respond_to?("tag_with")
    g = games(:battlelore)
    g.tag_with("carte action bluff")
    assert_equal "carte,action,bluff", g.tag_list
  end
  
  specify "game can have one image attched" do
    assert clean_game.respond_to?("image")
  end
  
  specify "shoud textilize description" do
    expected = "<p><strong>test</strong></p>"
    assert_equal expected, clean_game(:description => "*test*").description
  end
  
  specify "should have a can have some parties" do
    assert Party.count > 0
    assert games(:coloreto).respond_to?(:parties) 
  end
  
  specify "cannot be delete if have some parties played" do
    assert !games(:ever_played).destroy
  end
  
  specify "cannot be deleted if one person own it" do
    assert !games(:battlelore).destroy
  end
  
  specify "can have  authors" do
    assert clean_game.respond_to?(:authors)
    assert_equal 3, games(:coloreto).authors.count
    assert games(:coloreto).authors.include?(authors(:kinizia))
  end
  
  specify "must delete authorship if destroyed" do
    g = clean_game(:name => "Yspahan")
    assert g.save
    g.authors << authors(:kinizia)
    assert_equal 1,  g.authors.count
    assert g.destroy
    assert_equal 0, Authorship.find(:all, :conditions => {:game_id => g.id}).size
  end
  
  protected
  
  def clean_game(overrides = {})
    opts = {
      :name => "Elixir",
      :description => "Un petit jeu sympa ou de puissant magicien s'affronte a coup de sortilege ",
      :difficulty => 2,
      :min_player => 1,
      :max_player => 5,
      :price => 20
    }.merge(overrides)
    Game.new(opts)
  end
end
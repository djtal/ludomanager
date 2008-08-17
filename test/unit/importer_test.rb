require File.dirname(__FILE__) + '/../test_helper'

class ImporterTest < Test::Unit::TestCase
  fixtures :accounts, :games, :account_games, :authors, :authorships
  
  def setup
    super
    @raw = "jeux;Rapidcroco;;Cocktail Games;1;Fraga;;Cocktail Games;2004;J;GP;7;30mn;34;3,71;1;;;R;;2;3;4;;;;;;;;;;;;"
    @extract = "2;editeur;yr;J;classe;age;durÈe;nombre;moy;dif;m.c.;Ph;R;A;;;;;;;;;;;;;;;
    tag;Apero;18 jeux;_;;_;_;_;_;_;_;_;_;_;_;_;;;;;;;;;;;;;;;;;;;
    jeux;Ligretto Rouge;;Achat;1;_;;Scmidt;2000;;GP;8;20mn;13;3,69;1;;;_;;2;3;4;;;;;;;;;;;;
    jeux;Zygomar;;Cocktail Games;1;Ehrhard;;Cocktail Games;2006;J;GP;6;20mn;6;4,83;2;;;R;;2;3;4;;;;;;;;;;;;
    jeux;Rapidcroco;;Cocktail Games;1;Fraga;;Cocktail Games;2004;J;GP;7;30mn;34;3,71;1;;;R;;2;3;4;;;;;;;;;;;;
    jeux;Rapidcroco;;Cocktail Games;1;Ehrhard;;CocktailGames;2006;J;;6;_;2;4,00;_;;;R;;2;3;4;;;;;;;;;;;;"
  end
  
  def test_should_not_create_game_twice
    csv = "jeux;Rapidcroco;;Cocktail Games;1;Fraga;;Cocktail Games;2004;J;GP;7;30mn;34;3,71;1;;;R;;2;3;4;;;;;;;;;;;;
    jeux;Rapidcroco;;Cocktail Games;1;Ehrhard;;CocktailGames;2006;J;;6;_;2;4,00;_;;;R;;2;3;4;;;;;;;;;;;;"
    assert_difference "Game.count", 1 do
      LudoImporter.new.import(csv)
    end
  end
  
  def test_find_or_initialize_game_should_not_create_new_game_for_case_difference_in_name
    importer = LudoImporter.new
    assert_equal games(:coloreto), importer.find_or_initialize_game("ColoretO")
    assert_equal games(:coloreto), importer.find_or_initialize_game("CoLoReTo")
    
    assert_equal games(:coloreto_ext), importer.find_or_initialize_game("coloreto ext")
    assert_equal games(:coloreto_ext), importer.find_or_initialize_game("Coloreto Ext")
  end
  
  def test_find_or_create_author
    importer = LudoImporter.new
    assert_equal authors(:fraga), importer.find_or_create_author("Fraga")
    assert_nil importer.find_or_create_author("")
    assert_nil importer.find_or_create_author("_")
    a = importer.find_or_create_author("Ehrhard")
    assert !a.new_record?
    assert_equal "Ehrhard", a.name
  end
  
  def test_should_create_game_not_exist
    assert_difference "Game.count", 1 do
      LudoImporter.new.import(@raw)
    end
    g = Game.find_by_name("Rapidcroco")
    assert_equal "Cocktail Games", g.editor
    assert_equal 2, g.min_player
    assert_equal 4, g.max_player
  end
  
  def test_should_not_update_authors_if_ever_exist_in_game
    line = "jeux;coloreto;;Cocktail Games;1;Fraga;;Cocktail Games;2004;J;GP;7;30mn;34;3,71;1;;;R;;2;3;4;;;;;;;;;;;;"
    assert_no_difference "Authorship.count" do
      LudoImporter.new.import(line)
    end
  end
  
  def test_importer_should_not_overrides_old_games_attributes
    old_attributes = games(:coloreto).attributes
    LudoImporter.new.import("jeux;coloreto;;Cocktail Games;1;Fraga;;Cocktail Games;2004;J;GP;7;30mn;34;3,71;1;;;R;;2;3;4;;;;;;;;;;;;")
    assert_equal old_attributes, Game.find_by_name("coloreto").attributes
  end
  
  def test_importer_should_create_missing_game
    assert_difference "Game.count", 3 do
      LudoImporter.new.import(@extract)
    end

  end
  
  def test_importer_should_add_games_to_user
    a = Account.find_by_login("aaron")
    assert_equal 0, a.games.size
    LudoImporter.new(:account => a).import(@extract)
    assert_equal 3, a.games.count
  end
  
  def test_findPlayerRange_should_extract_min_lmax_player
    row = CSV.parse_line(@raw, ";")
    l = LudoImporter.new
    min, max = l.findPlayerRange(row)
    assert_equal 2, min
    assert_equal 4, max
  end
end
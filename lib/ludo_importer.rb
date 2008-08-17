class LudoImporter
  attr_accessor :account, :created_games, :imported_account_games
  
  def initialize(opts = {})
    @account = nil
    @account = opts[:account]
    @created_games = 0
    @imported_account_games = 0
  end
  
  # format is 0             ;1   ;2;3    ;5;6;7;8      ;
  # =>        type(jeux/tag);name;-;price;-;-;-;editeur;
  #
  #
  def import(data = "")
    CSV::Reader.parse(data, ";") do |row|
      game = find_or_initialize_game(row[1])
      if (game && game.new_record?)
        game.editor = row[9] if row[9]
        game.publish_year = row[10] if row[10]
        game.average = row[16] if row[16]
        game.min_player, game.max_player = findPlayerRange(row) 
        game.min_player = 2 if game.min_player == 0
        game.max_player = 4 if game.max_player == 0
        game.save
      end
      if @account && !@account.games.include?(game)
        ac = ::AccountGame.new do |ag|
          ag.price = row[3]
          ag.origin = row[4]
          ag.game_id = game.id
          ag.account = @account
        end
        ac.save
      end
    end
  end
  
  def find_or_initialize_game(name)
    unless name.blank?
      g = ::Game.find(:first, :conditions => ["LOWER(games.name) = ?", name.downcase])
      if (!g)
        g = ::Game.new(:name => name.downcase.humanize)
        @created_games += 1
      end
    end
    g
  end
  
  def find_or_create_author(name)
    if (name && name != "_" && name != "")
      a = ::Author.find(:first, :conditions => ["LOWER(authors.name) = ?", name.downcase])
      if (!a)
        a = ::Author.new(:name => name)
        a.save
      end
    end
    a
  end
  
    
  def self.import(filename)
    self.new.import(File.open(filename, 'r'))
  end
  
  
  
  def findPlayerRange(row)
    min = 0
    max = 0
    (22...34).each do |col|
      if (row[col].to_i > 0)
        min =row[col].to_i if min == 0
        min =  row[col].to_i if row[col].to_i <  min
        max =  row[col].to_i if row[col].to_i > max
      end
    end
    return min, max
  end
  
end
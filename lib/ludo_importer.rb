require "csv"

class LudoImporter
  attr_accessor :account
  
  def initialize(opts = {})
    @account = nil
    @account = opts[:account]
    
  end
  
  def import(data = "")
    curTag = ""
    CSV::Reader.parse(data, ";") do |row|
      type = row[0].gsub(/\s+/, "").downcase.to_sym if row[0]
      if type == :tag
        curTag = row[1].downcase if row[1]
      end
      if type == :jeux
        g = ::Game.find_or_initialize_by_name(row[1].downcase) if !row[1].nil? 
        g.editor = row[7]
        g.publish_year = row[8] if row[8]
        g.time_average = row[12] if row[12]
        g.min_player, g.max_player = findPlayerRange(row) 
        if (g.save)
          g.tag_with curTag if !curTag.blank?
        end
        if @account && !@account.games.include?(g)
          ag = AccountGame.new
          ag.account = @account
          ag.origin = row[3]
          ag.game = g
          ag.save
        end

      end
    end
  end
    
  def self.import(filename)
    self.new.import(File.open(filename, 'r'))
  end
  
  
  
  def findPlayerRange(row)
    min = 0
    max = 0
    (20...33).each do |col|
      if (row[col].to_i > 0)
        min =row[col].to_i if min == 0
        min =  row[col].to_i if row[col].to_i <  min
        max =  row[col].to_i if row[col].to_i > max
      end
    end
    return min, max
  end
  
end
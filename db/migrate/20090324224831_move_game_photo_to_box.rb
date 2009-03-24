class MoveGamePhotoToBox < ActiveRecord::Migration
  def self.up
    Game.find(:all).each do |game|
      if game.image
        game.box = File.open(game.image.full_filename)
        game.save
      end
    end
  end

  def self.down
  end
end

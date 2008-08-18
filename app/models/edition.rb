class Edition < ActiveRecord::Base
  Lang = [["Fr", 0], ["En", 1], ["De", 2], ["Multi", 3]]
  belongs_to :game
  belongs_to :editor
  validates_presence_of :game_id, :editor_id
end

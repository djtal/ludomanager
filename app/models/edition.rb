# == Schema Information
# Schema version: 20080817160324
#
# Table name: editions
#
#  id           :integer       not null, primary key
#  game_id      :integer       
#  editor_id    :integer       
#  lang         :text          
#  name         :text          
#  published_at :date          
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Edition < ActiveRecord::Base
  Lang = [["Fr", 0], ["En", 1], ["De", 2], ["Multi", 3]]
  belongs_to :game
  belongs_to :editor
  validates_presence_of :game_id, :editor_id
end

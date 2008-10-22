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
  Lang = ["fr", "en", "de", "multi"]
  belongs_to :game
  belongs_to :editor
  validates_presence_of :game_id, :editor_id
  validates_inclusion_of :lang, :in => Lang, :allow_nil => true, :allow_blank => true
  
  def select_name
    "#{editor.name} - #{lang} - #{published_at.year if published_at}"
  end
  

end

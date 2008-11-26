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
  belongs_to :game
  belongs_to :editor
  validates_presence_of :game_id, :editor_id
  validates_inclusion_of :lang, :in => ::Ludomanager::ISOCODES, :allow_nil => true, :allow_blank => true
  before_save :set_lang
  
  
  def select_name
    "#{editor.name} - #{lang} - #{published_at.year if published_at}"
  end
  
  def set_lang
    self.lang  = self.editor.lang if self.lang.blank?
  end
  

end

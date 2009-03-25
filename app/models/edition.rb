# == Schema Information
# Schema version: 20090324224831
#
# Table name: editions
#
#  id               :integer       not null, primary key
#  game_id          :integer(11)   
#  editor_id        :integer(11)   
#  lang             :text          
#  name             :text          
#  published_at     :date          
#  created_at       :datetime      
#  updated_at       :datetime      
#  box_file_name    :string(255)   
#  box_content_type :string(255)   
#  box_file_size    :integer       
#  box_updated_at   :datetime      
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

# encoding: UTF-8

class Edition < ActiveRecord::Base
  belongs_to :game
  belongs_to :editor, counter_cache: true
  validates_presence_of :game_id, :editor_id
  validates_inclusion_of :lang, in: ::Ludomanager::ISOCODES, allow_nil: true, allow_blank: true
  before_save :set_lang


  def select_name
    "#{editor.name} - #{lang} - #{published_at.year if published_at}"
  end

  def set_lang
    self.lang  = self.editor.lang if self.lang.blank?
  end


end

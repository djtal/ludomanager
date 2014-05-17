# encoding: UTF-8

class Edition < ActiveRecord::Base
  validates :game_id, :editor_id, presence: true
  validates :lang, inclusion: { in: ::Ludomanager::ISOCODES, allow_nil: true, allow_blank: true }

  belongs_to :game
  belongs_to :editor, counter_cache: true

  before_save :set_lang

  scope :for_text, lambda { |q| where('LOWER(name) like ?', "%#{q.downcase}%")}
  scope :latest, lambda { |l| order(created_at: :desc).limit(l) }

  def select_name
    "#{editor.name} - #{lang} - #{published_at.year if published_at}"
  end

  def set_lang
    self.lang  = self.editor.lang if self.lang.blank?
  end


end

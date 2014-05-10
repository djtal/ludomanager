# encoding: UTF-8

class Editor < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :lang, in: ::Ludomanager::ISOCODES, allow_nil: true, allow_blank: true

  has_attached_file :logo,
                    url: '/system/:attachment/:id/:style/:editor.:extension',
                    path: ':rails_root/public/system/:attachment/:id/:style/:editor.:extension',
                    default_url: '/system/:attachment/:style/missing.png'

  has_many :editions, dependent: :destroy
  has_many :games, through: :editions
end

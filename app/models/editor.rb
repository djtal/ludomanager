# encoding: UTF-8

class Editor < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :lang, inclusion: { in: ::Ludomanager::ISOCODES, allow_nil: true, allow_blank: true }

  has_attached_file :logo,
                    url: '/system/:attachment/:id/:style/:editor.:extension',
                    path: ':rails_root/public/system/:attachment/:id/:style/:editor.:extension',
                    default_url: '/system/:attachment/:style/missing.png'

  validates_attachment :logo, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  has_many :editions, dependent: :destroy
  has_many :games, through: :editions
end

# == Schema Information
# Schema version: 20090324224831
#
# Table name: editors
#
#  id                :integer       not null, primary key
#  name              :text          
#  homepage          :text          
#  created_at        :datetime      
#  updated_at        :datetime      
#  lang              :text          
#  logo_file_name    :string(255)   
#  logo_content_type :string(255)   
#  logo_file_size    :integer       
#  logo_updated_at   :datetime      
#

class Editor < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :lang, :in => ::Ludomanager::ISOCODES, :allow_nil => true, :allow_blank => true
  
  has_attached_file :logo,
                    :url => "/system/:attachment/:id/:style/:editor.:extension",
                    :path => ":rails_root/public/system/:attachment/:id/:style/:editor.:extension"
  
  has_one :logo_old, :as => :attachable, :class_name => "Asset"
  has_many :editions
  has_many :games, :through => :editions
end

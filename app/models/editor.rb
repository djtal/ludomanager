# == Schema Information
# Schema version: 20080817160324
#
# Table name: editors
#
#  id         :integer       not null, primary key
#  name       :text          
#  homepage   :text          
#  created_at :datetime      
#  updated_at :datetime      
#

class Editor < ActiveRecord::Base
  has_one :logo, :as => :attachable, :class_name => "Asset"
  has_many :editions
  has_many :games, :through => :editions
end

# == Schema Information
# Schema version: 20090324224831
#
# Table name: assets
#
#  id              :integer       not null, primary key
#  content_type    :string(255)   
#  filename        :string(255)   
#  size            :integer(11)   
#  width           :integer(11)   
#  height          :integer(11)   
#  attachable_id   :integer(11)   
#  attachable_type :string(255)   
#  created_at      :datetime      
#  updated_at      :datetime      
#

class Asset < ActiveRecord::Base
  has_attachment  :storage => :file_system, 
                  :content_type => :image
                  
  belongs_to :attachable, :polymorphic => true
end

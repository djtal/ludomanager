class Asset < ActiveRecord::Base
  has_attachment  :storage => :file_system, 
                  :content_type => :image
                  
  belongs_to :attachable, :polymorphic => true
end

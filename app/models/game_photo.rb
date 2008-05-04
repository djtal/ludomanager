# == Schema Information
# Schema version: 29
#
# Table name: game_photos
#
#  id           :integer       not null, primary key
#  content_type :string(255)   
#  filename     :string(255)   
#  size         :integer       
#  parent_id    :integer       
#  thumbnail    :string(255)   
#  width        :integer       
#  height       :integer       
#  game_id      :integer       
#

# == Schema Information
# Schema version: 29
#
# Table name: game_photos
#
#  id           :integer       not null, primary key
#  content_type :string(255)   
#  filename     :string(255)   
#  size         :integer       
#  parent_id    :integer       
#  thumbnail    :string(255)   
#  width        :integer       
#  height       :integer       
#  game_id      :integer       
#

class GamePhoto < ActiveRecord::Base
  belongs_to :game
  has_attachment :storage => :file_system
  
  #to convert old storage path with attchment fu partinionning system
  def partitioned_path(*args)
    args.unshift(id.to_s)
  end
end

# == Schema Information
# Schema version: 20080817160324
#
# Table name: game_photos
#
#  id           :integer       not null, primary key
#  content_type :string(255)   
#  filename     :string(255)   
#  size         :integer(11)   
#  parent_id    :integer(11)   
#  thumbnail    :string(255)   
#  width        :integer(11)   
#  height       :integer(11)   
#  game_id      :integer(11)   
#


class GamePhoto < ActiveRecord::Base
  belongs_to :game
  has_attachment :storage => :file_system
  
  #to convert old storage path with attchment fu partinionning system
  def partitioned_path(*args)
    args.unshift(id.to_s)
  end
end

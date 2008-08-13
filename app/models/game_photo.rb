
class GamePhoto < ActiveRecord::Base
  belongs_to :game
  has_attachment :storage => :file_system
  
  #to convert old storage path with attchment fu partinionning system
  def partitioned_path(*args)
    args.unshift(id.to_s)
  end
end

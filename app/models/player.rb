class Player < ActiveRecord::Base
  validates_presence_of :party_id, :member_id
  belongs_to :party
  belongs_to :member

  def display_name
    @name ||= member.display_name if member
  end
end

# == Schema Information
# Schema version: 20080817160324
#
# Table name: members
#
#  id         :integer       not null, primary key
#  name       :text          
#  nickname   :text          
#  account_id :integer       
#  created_at :datetime      
#  updated_at :datetime      
#  email      :text          
#

class Member < ActiveRecord::Base
  validates_presence_of :name, :account_id
  has_many :players
  has_many :parties, :through => :players
  belongs_to :account
  
  
  def gravatar_url
    "http://www.gravatar.com/avatar/#{MD5::md5(email)}"
  end
  
  def display_name
    "#{name} - #{nickname}"
  end
  
  def last_play_date
    parties.find(:first, :select => "parties.created_at", :order => "parties.created_at DESC").created_at.to_date
  end
  
  def played_game
    parties.count(:all, :group => :game)
  end
end

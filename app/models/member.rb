# == Schema Information
# Schema version: 20090324224831
#
# Table name: members
#
#  id         :integer       not null, primary key
#  name       :text          
#  nickname   :text          
#  account_id :integer(11)   
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
    last_play = parties.find(:first, :order => "parties.created_at DESC")
    last_play.created_at.to_date if last_play
  end
  
  
  def active?
    return false unless last_play_date
    last_play_date > 1.year.ago.to_date
  end
  
  def games_count
    parties.count(:game_id, :distinct => true)
  end
end

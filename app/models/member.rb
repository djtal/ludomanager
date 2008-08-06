# == Schema Information
#
# Table name: members
#
#  id         :integer       not null, primary key
#  name       :text          
#  nickname   :text          
#  account_id :integer       
#  created_at :datetime      
#  updated_at :datetime      
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
end

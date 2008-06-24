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
  validates_presence_of :name, :nickname, :account_id
  
  def gravatar_url
    "http://www.gravatar.com/avatar/#{MD5::md5(email)}"
  end
  
  def display_name
    "#{name} - #{nickname}"
  end
end

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
  
  
  # Import member data from csv file
  # format : name(mandatory);nickname(mandatory);email(optional)
  def self.import(data)
    imported = 0
    errors = []
    CSV::Reader.parse(data, ";") do |row|
      member = self.build(:name => row[0], :nickname => row[0])
      if member.save
        imported += 1
      else
        errors += member.errors
      end
    end
  end
  
  def gravatar_url
    "http://www.gravatar.com/avatar/#{MD5::md5(email)}"
  end
  
  def display_name
    "#{name} - #{nickname}"
  end
end

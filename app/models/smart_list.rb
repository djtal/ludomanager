# == Schema Information
# Schema version: 20080731203551
#
# Table name: smart_lists
#
#  id         :integer       not null, primary key
#  title      :text          
#  query      :text          
#  account_id :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class SmartList < ActiveRecord::Base
  validates_presence_of :account_id, :on => :create, :message => "can't be blank"
  validates_uniqueness_of :title, :on => :create, :message => "must be unique"
  
  belongs_to :account
  
  serialize :query
  
  def results
    account.account_games.search(:search => query)
  end
end

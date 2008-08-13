
class SmartList < ActiveRecord::Base
  validates_presence_of :account_id, :on => :create, :message => "can't be blank"
  validates_uniqueness_of :title, :on => :create, :message => "must be unique"
  
  belongs_to :account
  
  serialize :query
  
  def results
    account.account_games.search(:search => query)
  end
end

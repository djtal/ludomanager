class Member < ActiveRecord::Base
  validates_presence_of :name, :nickname, :account_id
end

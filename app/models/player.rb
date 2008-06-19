class Player < ActiveRecord::Base
  belongs_to :party
  belongs_to :member
end

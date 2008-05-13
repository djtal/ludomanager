# == Schema Information
# Schema version: 30
#
# Table name: authorships
#
#  id        :integer       not null, primary key
#  author_id :integer       
#  game_id   :integer       
#

# == Schema Information
# Schema version: 29
#
# Table name: authorships
#
#  id        :integer       not null, primary key
#  author_id :integer       
#  game_id   :integer       
#

class Authorship < ActiveRecord::Base
  validates_uniqueness_of :author_id, :scope => :game_id
  belongs_to :author
  belongs_to :game
end

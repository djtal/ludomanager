# == Schema Information
# Schema version: 20080731203551
#
# Table name: authorships
#
#  id        :integer       not null, primary key
#  author_id :integer(11)   
#  game_id   :integer(11)   
#

# == Schema Information
# Schema version: 20080710200139
#
# Table name: authorships
#
#  id        :integer       not null, primary key
#  author_id :integer       
#  game_id   :integer       
#


class Authorship < ActiveRecord::Base
  validates_presence_of :author_id, :game_id
  validates_uniqueness_of :author_id, :scope => :game_id
  belongs_to :author
  belongs_to :game
  
  # come from form under [{:display_name => "test"}, {:dislpay_name => "test1"}, {:display_name => "test2"}]
  def self.create_from_names(names = {})
    self.delete_all
    names.values.map{|h| h.values}.flatten.each do |name|
      self.create!(:author => Author.find_or_create_from_str(name))
    end
  end
end

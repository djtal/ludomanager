# encoding: UTF-8

class Authorship < ActiveRecord::Base
  validates_presence_of :author_id, :game_id
  validates_uniqueness_of :author_id, scope: :game_id
  belongs_to :author
  belongs_to :game

  # come from form under [{:display_name => "test"}, {:dislpay_name => "test1"}, {:display_name => "test2"}]
  def self.create_from_names(names = {})
    if names
      self.delete_all
      names.values.map { |h| h.values }.flatten.each do |name|
        self.create!(author: Author.find_or_create_from_str(name)) unless name.blank?
      end
    end
  end
end

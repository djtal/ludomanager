# encoding: UTF-8

class Authorship < ActiveRecord::Base
  validates :author_id, :game_id, presence: true
  validates :author_id, uniqueness: { scope: :game_id }

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
